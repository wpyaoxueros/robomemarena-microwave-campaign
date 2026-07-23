#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED="${SEED:-100}"
[[ "${SEED}" == "100" ]] || { echo "v129 is reserved for seed 100" >&2; exit 2; }
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ID="${RUN_ID:-task21_v129_seed100_${STAMP}}"
OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
SESSION="${SESSION:-task21_v129_${STAMP}_s100}"
JOB_NAME="${JOB_NAME:-task21v129_${STAMP}_s100}"
MEM_MB="${MEM_MB:-163840}"

mkdir -p "${OUT_ROOT}"
umask 077
RUNTIME_ENV="${OUT_ROOT}/retry_runtime.env"
{
  printf 'export PRIVATE_INPUTS_FILE=%q\n' "${PRIVATE_INPUTS_FILE}"
  printf 'export SEED=%q\n' "${SEED}"
  printf 'export NUM_TRIALS=4\n'
  printf 'export PORT=%q\n' "${PORT:-9820}"
  printf 'export OUTPUT_ROOT=%q\n' "${OUTPUT_ROOT}"
  printf 'export RUN_ID=%q\n' "${RUN_ID}"
  printf 'export OUT_ROOT=%q\n' "${OUT_ROOT}"
  printf 'export STAMP=%q\n' "${STAMP}_task21v129_s100"
} >"${RUNTIME_ENV}"
cp -p "${VERSION_DIR}/RETRY.md" "${VERSION_DIR}/run_worker.sh" \
  "${VERSION_DIR}/submit_seed100_zzhang510.sh" "${OUT_ROOT}/"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p acd_u --exclude=ACD1-61 --gres=gpu:2 -c8 --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} bash ${VERSION_DIR}/run_worker.sh ${RUNTIME_ENV} 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\nout_root=%s\nseed_start=100\nnum_trials=4\nexclude=ACD1-61\n' \
  "${SESSION}" "${JOB_NAME}" "${OUT_ROOT}"
