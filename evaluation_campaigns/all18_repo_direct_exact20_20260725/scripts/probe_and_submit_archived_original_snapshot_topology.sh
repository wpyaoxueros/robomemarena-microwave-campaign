#!/usr/bin/env bash
set -euo pipefail

# Probe the actual submit account, then launch the frozen original snapshot
# on the first partition that admits the exact two-GPU request.

TASK_ID=${1:?usage: probe_and_submit_archived_original_snapshot_topology.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUBMITTER="${CAMPAIGN_DIR}/scripts/submit_archived_original_snapshot_topology.sh"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
PROBE_LOG_DIR="${OUTPUT_ROOT}/probe_logs"
PROBE_LOG="${PROBE_LOG_DIR}/task${TASK_ID}_originalsnapshot66e789_${STAMP}.log"

[[ -f "${SUBMITTER}" ]] || { echo "missing submitter: ${SUBMITTER}" >&2; exit 2; }
mkdir -p "${PROBE_LOG_DIR}"

probe_partition() {
  local label="$1"
  local gpus="$2"
  local cpus="$3"
  local mem="$4"
  local part
  local probe_name

  for part in acd_u acd_ue emergency_acd; do
    probe_name="lhs_t${TASK_ID}_originalsnapshot_probe_${label}_${STAMP}"
    printf '[PROBE] label=%s partition=%s gpus=%s cpus=%s mem=%s\n' \
      "${label}" "${part}" "${gpus}" "${cpus}" "${mem}" | tee -a "${PROBE_LOG}" >&2
    if timeout 25s srun --immediate=20 -p "${part}" --gres="gpu:${gpus}" -c "${cpus}" \
      --mem="${mem}" --time=00:01:00 --job-name="${probe_name}" \
      bash -lc 'printf "PROBE_OK user=%s host=%s cudas=%s\\n" "$(whoami)" "$(hostname)" "${CUDA_VISIBLE_DEVICES:-unset}"; nvidia-smi -L | head -2' \
      >>"${PROBE_LOG}" 2>&1; then
      printf '[PROBE_OK] label=%s partition=%s\n' "${label}" "${part}" | tee -a "${PROBE_LOG}" >&2
      printf '%s\n' "${part}"
      return 0
    fi
    scancel --name="${probe_name}" -u "$(id -un)" >>"${PROBE_LOG}" 2>&1 || true
    printf '[PROBE_FAIL] label=%s partition=%s\n' "${label}" "${part}" | tee -a "${PROBE_LOG}" >&2
  done
  return 1
}

printf 'submitted_user=%s\nstamp=%s\ntask_id=%s\n' "$(id -un)" "${STAMP}" "${TASK_ID}" \
  >>"${PROBE_LOG}"
ONE_GPU_PARTITION="$(probe_partition onegpu 1 1 1024)"
TWO_GPU_PARTITION="$(probe_partition twogpu 2 16 327680)"

printf '[FORMAL] task=%s partition=%s\n' "${TASK_ID}" "${TWO_GPU_PARTITION}" \
  | tee -a "${PROBE_LOG}" >&2
OUTPUT_ROOT="${OUTPUT_ROOT}" PARTITION="${TWO_GPU_PARTITION}" STAMP="${STAMP}" \
  RUN_ID="task${TASK_ID}_originalsnapshot66e789_exact20_${STAMP}" \
  SESSION="lhs_t${TASK_ID}_originalsnapshot66e789_${STAMP}" \
  JOB_NAME="lhs_t${TASK_ID}_originalsnapshot66e789_${STAMP}" \
  bash "${SUBMITTER}" "${TASK_ID}" | tee -a "${PROBE_LOG}"

printf 'probe_log=%s\n' "${PROBE_LOG}"
