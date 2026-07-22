#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${SEED:?set SEED}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ID="${RUN_ID:-task21_v125_seed${SEED}_${STAMP}}"
OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
SESSION="${SESSION:-task21_v125_${STAMP}_s${SEED}}"
JOB_NAME="${JOB_NAME:-task21v125_${STAMP}_s${SEED}}"
MEM_MB="${MEM_MB:-163840}"

mkdir -p "${OUT_ROOT}"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/run_one.sh" "${VERSION_DIR}/submit_one_zzhang510.sh" \
  "${VERSION_DIR}/task21_v125_eef_tolerances.json" "${VERSION_DIR}/release_anchors.empty.object.json" "${OUT_ROOT}/"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p acd_u --gres=gpu:2 -c8 --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && CUDA_VISIBLE_DEVICES=0,1 PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} SEED=${SEED} PORT=${PORT} OUTPUT_ROOT=${OUTPUT_ROOT} RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/run_one.sh\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\nout_root=%s\nseed=%s\n' "${SESSION}" "${JOB_NAME}" "${OUT_ROOT}" "${SEED}"
