#!/usr/bin/env bash
set -euo pipefail

# Task2 intentionally keeps its historical frozen BDDL/evaluator route. This
# thin wrapper only verifies one visible GPU and binds both services to it.

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose a GPU" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 1 ]] || {
  echo "Task2 frozen single-GPU runner requires one visible device, got ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

FROZEN_RUNNER="${REPO_DIR}/success_packs/repro20_remote_metrics_20260704_175011/run_one.sh"
FROZEN_SOURCE=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/repro20_remote_metrics_20260704_175011
VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task2_r1_exact20_eval_20260701_135219/vlm_eval_ready/task2_r1_ckpt500_20260701_143058
VLA_CKPT=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999

for required in "${FROZEN_RUNNER}" "${FROZEN_SOURCE}/official_remote_66e7894/REMOTE_COMMIT.txt" \
  "${VLM_CKPT}" "${VLA_CKPT}"; do
  [[ -e "${required}" ]] || { echo "missing Task2 frozen asset: ${required}" >&2; exit 3; }
done

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task2_all18_frozen20_single_gpu_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/task2/${RUN_ID}"
mkdir -p "${OUT_ROOT}"

{
  printf 'task_id=2\n'
  printf 'run_id=%s\n' "${RUN_ID}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID}"
  printf 'frozen_source=%s\n' "${FROZEN_SOURCE}"
  printf 'remote_commit=%s\n' "$(tr -d '\n' <"${FROZEN_SOURCE}/official_remote_66e7894/REMOTE_COMMIT.txt")"
  printf 'frozen_runner_sha256=%s\n' "$(sha256sum "${FROZEN_RUNNER}" | awk '{print $1}')"
  printf 'vla_ckpt=%s\n' "${VLA_CKPT}"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'cuda_visible_devices_before_remap=%s\n' "${CUDA_VISIBLE_DEVICES}"
  printf 'vla_cuda_visible_devices=0\n'
  printf 'vlm_cuda_visible_devices=0\n'
} >"${OUT_ROOT}/direct20_manifest.env"

export CUDA_VISIBLE_DEVICES=0
export VLA_CUDA_VISIBLE_DEVICES=0
export VLM_CUDA_VISIBLE_DEVICES=0
export OFFICIAL_OUTPUT_ROOT="${OUT_ROOT}"
export OFFICIAL_RUN_STAMP="${RUN_ID}"
export OFFICIAL_NUM_TRIALS=20
export OFFICIAL_SEED=104
export OFFICIAL_MAX_STEPS=2000
export OFFICIAL_REPLAN_STEPS=5

exec bash "${FROZEN_RUNNER}" 2
