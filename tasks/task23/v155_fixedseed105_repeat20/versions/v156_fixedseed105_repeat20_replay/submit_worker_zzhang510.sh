#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${WORKER_ID:?set WORKER_ID in 0..4}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
WORKER_OUT_ROOT="${WORKER_OUT_ROOT:-${OUTPUT_ROOT}/task23_v156_worker${WORKER_ID}_${STAMP}}"
SESSION="${SESSION:-task23_v156_${STAMP}_w${WORKER_ID}}"
JOB_NAME="${JOB_NAME:-task23v156_${STAMP}_w${WORKER_ID}}"
MEM_MB="${MEM_MB:-163840}"

mkdir -p "${WORKER_OUT_ROOT}"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/run_worker.sh" "${VERSION_DIR}/submit_worker_zzhang510.sh" "${WORKER_OUT_ROOT}/"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p acd_u --gres=gpu:2 -c8 --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && CUDA_VISIBLE_DEVICES=0,1 PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} WORKER_ID=${WORKER_ID} PORT=${PORT} OUTPUT_ROOT=${OUTPUT_ROOT} WORKER_OUT_ROOT=${WORKER_OUT_ROOT} bash ${VERSION_DIR}/run_worker.sh\" 2>&1 | tee -a ${WORKER_OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\nworker_out_root=%s\nworker_id=%s\n' "${SESSION}" "${JOB_NAME}" "${WORKER_OUT_ROOT}" "${WORKER_ID}"
