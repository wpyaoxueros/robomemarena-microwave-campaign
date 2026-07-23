#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
DISPATCH_ROOT="${OUTPUT_ROOT}/task21_v127_dispatch_${STAMP}"
mkdir -p "${DISPATCH_ROOT}"

printf 'dispatch_started=%s\n' "$(date -Is)" >"${DISPATCH_ROOT}/LIVE_STATUS.txt"
srun -p acd_u --gres=gpu:1 -c2 --mem=8192M --time=00:01:00 --job-name="task21v127probe_${STAMP}" \
  bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null
printf 'probe=passed\nprobe_finished=%s\n' "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"

RUN_ID="task21_v127_seed107_${STAMP}"
PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" PORT=9801 OUTPUT_ROOT="${OUTPUT_ROOT}" RUN_ID="${RUN_ID}" \
  OUT_ROOT="${OUTPUT_ROOT}/${RUN_ID}" STAMP="${STAMP}_task21v127_s107" \
  SESSION="task21_v127_${STAMP}_s107" JOB_NAME="task21v127_${STAMP}_s107" MEM_MB=163840 \
  bash "${VERSION_DIR}/submit_one_zzhang510.sh"

printf 'submission=created\nfinished=%s\n' "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"
