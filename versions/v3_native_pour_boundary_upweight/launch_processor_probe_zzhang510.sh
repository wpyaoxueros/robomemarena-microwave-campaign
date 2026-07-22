#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${COMPAT_MODEL_DIR:?set COMPAT_MODEL_DIR}"
: "${PROBE_OUTPUT_ROOT:?set PROBE_OUTPUT_ROOT}"

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
OUT_ROOT="${PROBE_OUTPUT_ROOT}/task22_v3_compat_processor_probe_${STAMP}"
mkdir -p "${OUT_ROOT}"
printf 'status=started\nstarted_at=%s\n' "$(date -Is)" >"${OUT_ROOT}/LIVE_STATUS.txt"

# A same-shell GPU allocation confirms this borrowed account is currently usable.
srun -p acd_u --gres=gpu:1 -c2 --mem=8192M --time=00:01:00 --job-name="task22compatalloc_${STAMP}" \
  bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null'
printf 'slurm_probe=passed\n' >>"${OUT_ROOT}/LIVE_STATUS.txt"

MAX_PER_CPU="$(scontrol show partition acd_u | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p' | head -n1)"
MEM_MB="$(( 8 * ${MAX_PER_CPU:-20480} ))"
set +e
srun -p acd_u --gres=gpu:1 -c8 --mem="${MEM_MB}M" --time=00:10:00 --job-name="task22compatproc_${STAMP}" \
  bash -lc "cd ${VERSION_DIR} && PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} COMPAT_MODEL_DIR=${COMPAT_MODEL_DIR} bash ${VERSION_DIR}/probe_processor_compat.sh" \
  2>&1 | tee "${OUT_ROOT}/processor_probe.log"
RC="${PIPESTATUS[0]}"
set -e
printf 'processor_probe_exit=%s\nfinished_at=%s\n' "${RC}" "$(date -Is)" >>"${OUT_ROOT}/LIVE_STATUS.txt"
exit "${RC}"
