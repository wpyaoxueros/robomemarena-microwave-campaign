#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${SEED:?set SEED}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ID="${RUN_ID:-task22_v2_seed${SEED}_${STAMP}}"
OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
MEM_MB="${MEM_MB:-2000000}"
PROBE_JOB_NAME="${PROBE_JOB_NAME:-task22v2_probe_${STAMP}_s${SEED}}"
SESSION="${SESSION:-task22_v2_${STAMP}_s${SEED}}"
JOB_NAME="${JOB_NAME:-task22v2_${STAMP}_s${SEED}}"
mkdir -p "${OUT_ROOT}"

# Redirecting probe stdin prevents srun from consuming the remaining dispatcher
# script when this file is passed to a remote shell through stdin.
srun -p acd_u --gres=gpu:1 -c2 --mem="${MEM_MB}"M --time=00:02:00 --immediate=120 \
  --job-name="${PROBE_JOB_NAME}" \
  bash -lc 'printf "PROBE_USER=%s ACCOUNT=%s NODE=%s\\n" "$(id -un)" "${SLURM_JOB_ACCOUNT:-none}" "${SLURMD_NODENAME:-none}"; nvidia-smi -L' \
  </dev/null | tee "${OUT_ROOT}/probe.log"
probe_rc=${PIPESTATUS[0]}
[[ "${probe_rc}" -eq 0 ]] || { echo "probe failed: ${probe_rc}" >&2; exit "${probe_rc}"; }

USER=zzhang510 \
PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
SEED="${SEED}" \
PORT="${PORT}" \
OUTPUT_ROOT="${OUTPUT_ROOT}" \
RUN_ID="${RUN_ID}" \
OUT_ROOT="${OUT_ROOT}" \
STAMP="${STAMP}" \
SESSION="${SESSION}" \
JOB_NAME="${JOB_NAME}" \
MEM_MB="${MEM_MB}" \
bash "${VERSION_DIR}/submit_one_zzhang510.sh"
