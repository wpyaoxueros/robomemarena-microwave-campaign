#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"

: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${TASK22_V3_DATASET:?set TASK22_V3_DATASET}"
: "${TASK22_V3_DATA_MANIFEST:?set TASK22_V3_DATA_MANIFEST}"
: "${TRAIN_OUTPUT_ROOT:?set TRAIN_OUTPUT_ROOT}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are unreadable" >&2; exit 2; }
[[ -r "${TASK22_V3_DATASET}" ]] || { echo "v3 dataset is unreadable" >&2; exit 2; }
[[ -r "${TASK22_V3_DATA_MANIFEST}" ]] || { echo "v3 data manifest is unreadable" >&2; exit 2; }

# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
: "${OPENPI_ROOT:?private inputs must define OPENPI_ROOT}"
VLM_INPUT_CHECKPOINT="${VLM_INPUT_CHECKPOINT:-${VLM_CKPT:-}}"
[[ -n "${VLM_INPUT_CHECKPOINT}" ]] || { echo "private inputs must define VLM_INPUT_CHECKPOINT or VLM_CKPT" >&2; exit 2; }

OPENPI_PYTHON="${OPENPI_PYTHON:-$(dirname "${OPENPI_ROOT}")/conda_envs/openpi/bin/python}"
TRAIN_SCRIPT="${TRAIN_SCRIPT:-${OPENPI_ROOT}/examples/train_task1_qwen3_vl_lfp_fullft_hf.py}"
DEEPSPEED_CONFIG="${DEEPSPEED_CONFIG:-${OPENPI_ROOT}/tmp/deepspeed_zero3_bf16_auto.json}"
for required_file in "${OPENPI_PYTHON}" "${TRAIN_SCRIPT}" "${DEEPSPEED_CONFIG}"; do
  [[ -r "${required_file}" ]] || { echo "missing runtime file ${required_file}" >&2; exit 2; }
done

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ID="${RUN_ID:-task22_v3_native_boundary_${STAMP}}"
RUN_ROOT="${TRAIN_OUTPUT_ROOT}/${RUN_ID}"
CHECKPOINT_DIR="${RUN_ROOT}/checkpoint"
LOG_FILE="${RUN_ROOT}/train.log"
MASTER_PORT="${MASTER_PORT:-29622}"
PER_DEVICE_BS="${PER_DEVICE_BS:-2}"
GRAD_ACC="${GRAD_ACC:-2}"
MAX_STEPS="${MAX_STEPS:-500}"
SAVE_STEPS="${SAVE_STEPS:-250}"

mkdir -p "${RUN_ROOT}"
cp -p "${VERSION_DIR}/PRE_TRAIN.md" "${VERSION_DIR}/run_train.sh" "${RUN_ROOT}/"
{
  printf 'git_commit=%s\n' "$(git -C "${REPO_DIR}" rev-parse HEAD)"
  printf 'dataset_sha256=%s\n' "$(sha256sum "${TASK22_V3_DATASET}" | awk '{print $1}')"
  printf 'dataset_manifest_sha256=%s\n' "$(sha256sum "${TASK22_V3_DATA_MANIFEST}" | awk '{print $1}')"
  printf 'per_device_batch=%s\ngrad_acc=%s\nmax_steps=%s\nsave_steps=%s\n' \
    "${PER_DEVICE_BS}" "${GRAD_ACC}" "${MAX_STEPS}" "${SAVE_STEPS}"
  printf 'optimizer_resume=false\n'
  printf 'oracle_prompt_injection=false\n'
} >"${RUN_ROOT}/RUN_MANIFEST.txt"

export PYTHONNOUSERSITE=1
export TOKENIZERS_PARALLELISM=false
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

cd "${OPENPI_ROOT}"
torchrun --nproc_per_node=2 --master_port="${MASTER_PORT}" "${TRAIN_SCRIPT}" \
  --dataset "${TASK22_V3_DATASET}" \
  --model "${VLM_INPUT_CHECKPOINT}" \
  --output_dir "${CHECKPOINT_DIR}" \
  --seed 42 \
  --eval_ratio 0.0 \
  --num_train_epochs 10 \
  --per_device_train_batch_size "${PER_DEVICE_BS}" \
  --per_device_eval_batch_size 1 \
  --gradient_accumulation_steps "${GRAD_ACC}" \
  --learning_rate 1e-5 \
  --logging_steps 1 \
  --save_steps "${SAVE_STEPS}" \
  --save_total_limit 4 \
  --max_length 4096 \
  --dataloader_num_workers 8 \
  --max_train_samples 0 \
  --max_steps "${MAX_STEPS}" \
  --eval_strategy no \
  --save_strategy steps \
  --deepspeed_config "${DEEPSPEED_CONFIG}" \
  --freeze_vision_tower \
  --predictive_coding_head \
  2>&1 | tee -a "${LOG_FILE}"
