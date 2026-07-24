#!/usr/bin/env bash
set -euo pipefail
umask 0002

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="${PY:-/data/user/hlei573/conda_envs/qwen35_train/bin/python}"
GENERIC_TRAIN="/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/train_vlm_successstyle_frombase_generic.sh"

DATASET_JSONL="${DATASET_JSONL:?Set DATASET_JSONL.}"
BASE_MODEL="${BASE_MODEL:-/data/user/zzhang510/hlei573_borrow_outputs/counting_task7_pickpour1_balanced_vlm_2gpu_acdu_retry_20260724_080151/vlm_eval_ready/checkpoint-750}"
OUTDIR="${OUTDIR:?Set OUTDIR.}"
LOGDIR="${LOGDIR:-${OUTDIR}/logs}"
LOGFILE="${LOGFILE:-${LOGDIR}/train.log}"

for path in "${PY}" "${GENERIC_TRAIN}" "${DATASET_JSONL}" "${BASE_MODEL}/model.safetensors" "${BASE_MODEL}/processor_config.json"; do
  [[ -e "${path}" ]] || { echo "[ERROR] missing ${path}" >&2; exit 1; }
done

mkdir -p "${OUTDIR}" "${LOGDIR}"
{
  echo "package_git_commit=$(git -C "${PACK_DIR}" rev-parse HEAD)"
  echo "submitted_user=$(whoami)"
  echo "slurm_job_id=${SLURM_JOB_ID:-none}"
  echo "slurm_job_account=${SLURM_JOB_ACCOUNT:-unknown}"
  echo "slurm_job_partition=${SLURM_JOB_PARTITION:-unknown}"
  echo "slurm_node=${SLURMD_NODENAME:-$(hostname)}"
  echo "cuda_visible_devices=${CUDA_VISIBLE_DEVICES:-unset}"
  echo "dataset_jsonl=${DATASET_JSONL}"
  echo "dataset_sha256=$(sha256sum "${DATASET_JSONL}" | awk '{print $1}')"
  echo "base_model=${BASE_MODEL}"
  echo "base_model_sha256=$(sha256sum "${BASE_MODEL}/model.safetensors" | awk '{print $1}')"
  echo "training_mode=continue_from_task7_pickpour1_balanced_checkpoint750"
  echo "transition_labels=eval_hardcase_pour1_persistence_plus_pour2"
  echo "place_label_training=disabled"
} | tee "${OUTDIR}/run_manifest.txt"

exec env \
  PY="${PY}" \
  BASE_MODEL="${BASE_MODEL}" \
  DATASET_JSONL="${DATASET_JSONL}" \
  OUTDIR="${OUTDIR}" \
  RUN_NAME="task07_evalpour1_hardcase" \
  LOGDIR="${LOGDIR}" \
  LOGFILE="${LOGFILE}" \
  NPROC_PER_NODE="${NPROC_PER_NODE:-2}" \
  PER_DEVICE_BS="${PER_DEVICE_BS:-2}" \
  GRAD_ACC="${GRAD_ACC:-2}" \
  MAX_STEPS="${MAX_STEPS:-750}" \
  SAVE_STEPS="${SAVE_STEPS:-250}" \
  SAVE_TOTAL_LIMIT="${SAVE_TOTAL_LIMIT:-4}" \
  DATALOADER_NUM_WORKERS="${DATALOADER_NUM_WORKERS:-8}" \
  "${GENERIC_TRAIN}"
