#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${OPENPI_PYTHON:?set OPENPI_PYTHON}"
: "${PROBE_OUTPUT_ROOT:?set PROBE_OUTPUT_ROOT}"

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ID="${RUN_ID:-task22_v4_device_binding_${STAMP}}"
MASTER_PORT="${MASTER_PORT:-29630}"
WORLD_SIZE="${WORLD_SIZE:-2}"
REQUIRE_CLEAN="${REQUIRE_CLEAN:-1}"
RUN_ROOT="${PROBE_OUTPUT_ROOT}/${RUN_ID}"
LOG_FILE="${RUN_ROOT}/probe.log"

mkdir -p "${RUN_ROOT}"
{
  printf 'status=starting\nstarted_at=%s\n' "$(date -Is)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID:-}"
  printf 'slurm_job_gpus=%s\n' "${SLURM_JOB_GPUS:-}"
  printf 'cuda_visible_devices=%s\n' "${CUDA_VISIBLE_DEVICES:-}"
  printf 'world_size=%s\n' "${WORLD_SIZE}"
  printf 'require_clean=%s\n' "${REQUIRE_CLEAN}"
} >"${RUN_ROOT}/LIVE_STATUS.txt"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/collect_gpu_preflight.py" \
  "${VERSION_DIR}/probe_gpu_binding.py" "${VERSION_DIR}/run_device_binding_probe.sh" "${RUN_ROOT}/"

PRE_ARGS=(--report "${RUN_ROOT}/gpu_preflight.json" --expected-world-size "${WORLD_SIZE}")
if [[ "${REQUIRE_CLEAN}" == "1" ]]; then
  PRE_ARGS+=(--require-clean)
fi

set +e
"${OPENPI_PYTHON}" "${VERSION_DIR}/collect_gpu_preflight.py" "${PRE_ARGS[@]}" 2>&1 | tee -a "${LOG_FILE}"
PRE_RC="${PIPESTATUS[0]}"
set -e
if [[ "${PRE_RC}" -ne 0 ]]; then
  printf 'status=preflight_rejected\nexit=%s\nfinished_at=%s\n' "${PRE_RC}" "$(date -Is)" >>"${RUN_ROOT}/LIVE_STATUS.txt"
  exit "${PRE_RC}"
fi

set +e
"${OPENPI_PYTHON}" -m torch.distributed.run --nproc_per_node="${WORLD_SIZE}" --master_port="${MASTER_PORT}" \
  "${VERSION_DIR}/probe_gpu_binding.py" --report "${RUN_ROOT}/rank_binding.json" 2>&1 | tee -a "${LOG_FILE}"
BIND_RC="${PIPESTATUS[0]}"
set -e
if [[ "${BIND_RC}" -ne 0 ]]; then
  printf 'status=rank_binding_failed\nexit=%s\nfinished_at=%s\n' "${BIND_RC}" "$(date -Is)" >>"${RUN_ROOT}/LIVE_STATUS.txt"
  exit "${BIND_RC}"
fi
printf 'status=passed\nfinished_at=%s\n' "$(date -Is)" >>"${RUN_ROOT}/LIVE_STATUS.txt"
