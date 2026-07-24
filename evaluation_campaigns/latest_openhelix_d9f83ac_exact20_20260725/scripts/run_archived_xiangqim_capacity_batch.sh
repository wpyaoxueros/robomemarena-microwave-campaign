#!/usr/bin/env bash
set -euo pipefail

# Run inside a three- or five-GPU Slurm allocation. Every formal worker gets a
# VLA/VLM pair. The final allocated GPU always runs a separate one-episode
# same-GPU compatibility preflight and is excluded from formal aggregation.
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_PRIVATE_DIR=${RUNTIME_PRIVATE_DIR:?set RUNTIME_PRIVATE_DIR}
OUTPUT_ROOT_OVERRIDE=${OUTPUT_ROOT_OVERRIDE:?set OUTPUT_ROOT_OVERRIDE}
[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside Slurm" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not set CUDA_VISIBLE_DEVICES" >&2; exit 2; }

IFS=',' read -r -a GPU_IDS <<< "${CUDA_VISIBLE_DEVICES}"
GPU_COUNT=${#GPU_IDS[@]}
case "${GPU_COUNT}" in
  3|5) ;;
  *) echo "expected three or five allocated GPUs, got: ${CUDA_VISIBLE_DEVICES}" >&2; exit 2 ;;
esac

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
SEED=${SEED:-104}
BATCH_ROOT="${OUTPUT_ROOT_OVERRIDE}/lhs_gpu_batches/${STAMP}"
mkdir -p "${BATCH_ROOT}/logs"

cat > "${BATCH_ROOT}/batch_manifest.env" <<EOF
kind=formal_exact20_workers_plus_single_gpu_preflight
unix_user=$(id -un)
slurm_job_id=${SLURM_JOB_ID}
remote_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
seed=${SEED}
allocated_gpu_ids=${CUDA_VISIBLE_DEVICES}
gpu_count=${GPU_COUNT}
formal_task12_gpu_ids=${GPU_IDS[0]},${GPU_IDS[1]}
preflight_task12_gpu_id=${GPU_IDS[$((GPU_COUNT - 1))]}
EOF
if [[ "${GPU_COUNT}" == "5" ]]; then
  echo "formal_task13_gpu_ids=${GPU_IDS[2]},${GPU_IDS[3]}" >> "${BATCH_ROOT}/batch_manifest.env"
fi

run_formal() {
  local task_id=$1
  local gpu_ids=$2
  local port=$3
  local env_file="${RUNTIME_PRIVATE_DIR}/archived_task${task_id}.env"
  local log_file="${BATCH_ROOT}/logs/task${task_id}_formal.log"
  env \
    CUDA_VISIBLE_DEVICES="${gpu_ids}" \
    RUNTIME_ENV="${env_file}" \
    OUTPUT_ROOT_OVERRIDE="${OUTPUT_ROOT_OVERRIDE}" \
    ARCHIVED_TASKS_EVAL_OVERRIDE="${CAMPAIGN_DIR}/adapters/eval_tasks2_26_sync_endpose_hold_d9_compat.py" \
    PORT="${port}" \
    SEED="${SEED}" \
    bash "${CAMPAIGN_DIR}/scripts/run_archived_exact20_inside_allocation.sh" \
      "${task_id}" "${env_file}" >"${log_file}" 2>&1
}

run_preflight() {
  local preflight_gpu=${GPU_IDS[$((GPU_COUNT - 1))]}
  local env_file="${RUNTIME_PRIVATE_DIR}/archived_task12.env"
  env \
    CUDA_VISIBLE_DEVICES="${preflight_gpu}" \
    OUTPUT_ROOT_OVERRIDE="${OUTPUT_ROOT_OVERRIDE}" \
    PORT=9712 \
    SEED=124 \
    bash "${CAMPAIGN_DIR}/scripts/run_archived_single_gpu_preflight.sh" \
      12 "${env_file}" >"${BATCH_ROOT}/logs/task12_colocation_preflight.log" 2>&1
}

run_formal 12 "${GPU_IDS[0]},${GPU_IDS[1]}" 9412 &
pid_task12=$!
if [[ "${GPU_COUNT}" == "5" ]]; then
  run_formal 13 "${GPU_IDS[2]},${GPU_IDS[3]}" 9413 &
  pid_task13=$!
fi
run_preflight &
pid_preflight=$!

set +e
wait "${pid_task12}"; status_task12=$?
if [[ "${GPU_COUNT}" == "5" ]]; then
  wait "${pid_task13}"; status_task13=$?
else
  status_task13=NA
fi
wait "${pid_preflight}"; status_preflight=$?
set -e

cat > "${BATCH_ROOT}/batch_exit_status.tsv" <<EOF
workload\texit_status\tlog
task12_formal_exact20\t${status_task12}\t${BATCH_ROOT}/logs/task12_formal.log
task13_formal_exact20\t${status_task13}\t${BATCH_ROOT}/logs/task13_formal.log
task12_single_gpu_preflight\t${status_preflight}\t${BATCH_ROOT}/logs/task12_colocation_preflight.log
EOF

if [[ ${status_task12} -ne 0 || ${status_preflight} -ne 0 ]]; then
  exit 1
fi
if [[ "${GPU_COUNT}" == "5" && ${status_task13} -ne 0 ]]; then
  exit 1
fi
