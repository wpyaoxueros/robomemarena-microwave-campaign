#!/usr/bin/env bash
set -euo pipefail

# Run inside one five-GPU Slurm allocation. Two unchanged formal VLM+VLA
# workers receive two GPUs each; a third process receives the final GPU for a
# one-episode VLM+VLA colocation preflight. Private checkpoint paths remain in
# the runtime env files and are never stored in this repository.
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_PRIVATE_DIR=${RUNTIME_PRIVATE_DIR:?set RUNTIME_PRIVATE_DIR}
OUTPUT_ROOT_OVERRIDE=${OUTPUT_ROOT_OVERRIDE:?set OUTPUT_ROOT_OVERRIDE}
[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside Slurm" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not set CUDA_VISIBLE_DEVICES" >&2; exit 2; }

IFS=',' read -r -a GPU_IDS <<< "${CUDA_VISIBLE_DEVICES}"
[[ ${#GPU_IDS[@]} -eq 5 ]] || {
  echo "expected exactly five allocated GPUs, got: ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
SEED=${SEED:-104}
BATCH_ROOT="${OUTPUT_ROOT_OVERRIDE}/lhs_five_gpu_batches/${STAMP}"
mkdir -p "${BATCH_ROOT}/logs"

cat > "${BATCH_ROOT}/batch_manifest.env" <<EOF
kind=two_formal_exact20_plus_single_gpu_preflight
unix_user=$(id -un)
slurm_job_id=${SLURM_JOB_ID}
remote_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
seed=${SEED}
allocated_gpu_ids=${CUDA_VISIBLE_DEVICES}
formal_task12_gpu_ids=${GPU_IDS[0]},${GPU_IDS[1]}
formal_task13_gpu_ids=${GPU_IDS[2]},${GPU_IDS[3]}
preflight_task12_gpu_id=${GPU_IDS[4]}
EOF

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
  local env_file="${RUNTIME_PRIVATE_DIR}/archived_task12.env"
  env \
    CUDA_VISIBLE_DEVICES="${GPU_IDS[4]}" \
    OUTPUT_ROOT_OVERRIDE="${OUTPUT_ROOT_OVERRIDE}" \
    PORT=9712 \
    SEED=124 \
    bash "${CAMPAIGN_DIR}/scripts/run_archived_single_gpu_preflight.sh" \
      12 "${env_file}" >"${BATCH_ROOT}/logs/task12_colocation_preflight.log" 2>&1
}

run_formal 12 "${GPU_IDS[0]},${GPU_IDS[1]}" 9412 &
pid_task12=$!
run_formal 13 "${GPU_IDS[2]},${GPU_IDS[3]}" 9413 &
pid_task13=$!
run_preflight &
pid_preflight=$!

set +e
wait "${pid_task12}"; status_task12=$?
wait "${pid_task13}"; status_task13=$?
wait "${pid_preflight}"; status_preflight=$?
set -e

cat > "${BATCH_ROOT}/batch_exit_status.tsv" <<EOF
workload\texit_status\tlog
task12_formal_exact20\t${status_task12}\t${BATCH_ROOT}/logs/task12_formal.log
task13_formal_exact20\t${status_task13}\t${BATCH_ROOT}/logs/task13_formal.log
task12_single_gpu_preflight\t${status_preflight}\t${BATCH_ROOT}/logs/task12_colocation_preflight.log
EOF

if [[ ${status_task12} -ne 0 || ${status_task13} -ne 0 || ${status_preflight} -ne 0 ]]; then
  exit 1
fi
