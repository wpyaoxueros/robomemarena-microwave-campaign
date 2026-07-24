#!/usr/bin/env bash
set -euo pipefail

# Every worker receives exactly one Slurm GPU. The unchanged generic rollout
# runner then binds its VLA server and VLM evaluator to that same GPU.
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_PRIVATE_DIR=${RUNTIME_PRIVATE_DIR:?set RUNTIME_PRIVATE_DIR}
OUTPUT_ROOT_OVERRIDE=${OUTPUT_ROOT_OVERRIDE:?set OUTPUT_ROOT_OVERRIDE}
TASK_IDS=${TASK_IDS:-12,13,18}
[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside Slurm" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not set CUDA_VISIBLE_DEVICES" >&2; exit 2; }

IFS=',' read -r -a GPU_IDS <<< "${CUDA_VISIBLE_DEVICES}"
IFS=',' read -r -a TASK_LIST <<< "${TASK_IDS}"
[[ ${#TASK_LIST[@]} -le ${#GPU_IDS[@]} ]] || {
  echo "need one GPU per task: tasks=${TASK_IDS} gpus=${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

for task_id in "${TASK_LIST[@]}"; do
  case "${task_id}" in
    3|12|13|18|25|26) ;;
    *) echo "unsupported archived exact20 task: ${task_id}" >&2; exit 2 ;;
  esac
done

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
SEED=${SEED:-104}
BATCH_ROOT="${OUTPUT_ROOT_OVERRIDE}/lhs_single_gpu_batches/${STAMP}"
mkdir -p "${BATCH_ROOT}/logs"

{
  echo "kind=single_gpu_formal_exact20_workers"
  echo "unix_user=$(id -un)"
  echo "slurm_job_id=${SLURM_JOB_ID}"
  echo "remote_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1"
  echo "seed=${SEED}"
  echo "allocated_gpu_ids=${CUDA_VISIBLE_DEVICES}"
  echo "task_ids=${TASK_IDS}"
  for index in "${!TASK_LIST[@]}"; do
    echo "task${TASK_LIST[$index]}_gpu_id=${GPU_IDS[$index]}"
  done
} > "${BATCH_ROOT}/batch_manifest.env"

run_task() {
  local task_id=$1
  local gpu_id=$2
  local port=$3
  local env_file="${RUNTIME_PRIVATE_DIR}/archived_task${task_id}.env"
  local log_file="${BATCH_ROOT}/logs/task${task_id}.log"
  env \
    CUDA_VISIBLE_DEVICES="${gpu_id}" \
    RUNTIME_ENV="${env_file}" \
    OUTPUT_ROOT_OVERRIDE="${OUTPUT_ROOT_OVERRIDE}" \
    ARCHIVED_TASKS_EVAL_OVERRIDE="${CAMPAIGN_DIR}/adapters/eval_tasks2_26_sync_endpose_hold_d9_compat.py" \
    PORT="${port}" \
    SEED="${SEED}" \
    bash "${CAMPAIGN_DIR}/scripts/run_archived_exact20_inside_allocation.sh" \
      "${task_id}" "${env_file}" >"${log_file}" 2>&1
}

pids=()
for index in "${!TASK_LIST[@]}"; do
  task_id=${TASK_LIST[$index]}
  gpu_id=${GPU_IDS[$index]}
  port=$((9400 + task_id))
  run_task "${task_id}" "${gpu_id}" "${port}" &
  pids+=("$!")
done

overall_status=0
{
  printf 'task_id\texit_status\tlog\n'
  for index in "${!TASK_LIST[@]}"; do
    task_id=${TASK_LIST[$index]}
    set +e
    wait "${pids[$index]}"
    status=$?
    set -e
    printf '%s\t%s\t%s\n' "${task_id}" "${status}" "${BATCH_ROOT}/logs/task${task_id}.log"
    if [[ ${status} -ne 0 ]]; then
      overall_status=1
    fi
  done
} > "${BATCH_ROOT}/batch_exit_status.tsv"

exit "${overall_status}"
