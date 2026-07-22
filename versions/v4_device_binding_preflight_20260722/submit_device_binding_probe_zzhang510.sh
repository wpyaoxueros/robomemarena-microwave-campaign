#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${OPENPI_PYTHON:?set OPENPI_PYTHON}"
: "${PROBE_OUTPUT_ROOT:?set PROBE_OUTPUT_ROOT}"

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
DISPATCH_ROOT="${PROBE_OUTPUT_ROOT}/task22_v4_device_binding_dispatch_${STAMP}"
mkdir -p "${DISPATCH_ROOT}"
printf 'status=started\nstarted_at=%s\n' "$(date -Is)" >"${DISPATCH_ROOT}/LIVE_STATUS.txt"

srun -p acd_u --gres=gpu:1 -c2 --mem=8192M --time=00:01:00 --job-name="task22v4alloc_${STAMP}" \
  bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null
printf 'slurm_probe=passed\n' >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"

MAX_PER_CPU="$(scontrol show partition acd_u | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p' | head -n1)"
MEM_MB="$(( 16 * ${MAX_PER_CPU:-20480} ))"
NODE_ARGS=()
if [[ -n "${NODELIST:-}" ]]; then
  NODE_ARGS=(--nodelist="${NODELIST}")
fi

set +e
srun -p acd_u --gres=gpu:2 -c16 --mem="${MEM_MB}M" --time=00:15:00 --job-name="task22v4bind_${STAMP}" "${NODE_ARGS[@]}" \
  bash -lc "cd ${VERSION_DIR} && OPENPI_PYTHON=${OPENPI_PYTHON} PROBE_OUTPUT_ROOT=${PROBE_OUTPUT_ROOT} RUN_ID=task22_v4_device_binding_${STAMP} MASTER_PORT=29630 REQUIRE_CLEAN=1 STAMP=${STAMP} bash ${VERSION_DIR}/run_device_binding_probe.sh" \
  2>&1 | tee -a "${DISPATCH_ROOT}/probe.log"
RC="${PIPESTATUS[0]}"
set -e
printf 'probe_exit=%s\nfinished_at=%s\n' "${RC}" "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"
exit "${RC}"
