#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${INPUTS_FILE:?set INPUTS_FILE to an untracked private environment file}"
[[ -f "${INPUTS_FILE}" ]] || { echo "missing ${INPUTS_FILE}" >&2; exit 2; }

NODE="${NODE:-ACD1-1}"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
OUT_BASE="${OUT_BASE:?set OUT_BASE to the shared irpn output root}"
WORKER_OUT_ROOT="${WORKER_OUT_ROOT:-${OUT_BASE}/task23_v157_acd1_1_serial20_${STAMP}}"
SESSION="${SESSION:-task23_v157_${STAMP}}"
JOB_NAME="${JOB_NAME:-task23v157_${STAMP}}"
PORT="${PORT:-9760}"

# Request all currently available node memory without hard-coding the size.
node_info="$(scontrol show node "${NODE}")"
real_mem="$(sed -n 's/.*RealMemory=\([0-9][0-9]*\).*/\1/p' <<<"${node_info}" | head -n1)"
alloc_mem="$(sed -n 's/.*AllocMem=\([0-9][0-9]*\).*/\1/p' <<<"${node_info}" | head -n1)"
[[ -n "${real_mem}" ]] || { echo "cannot determine RealMemory for ${NODE}" >&2; exit 2; }
alloc_mem="${alloc_mem:-0}"
MEM_MB="${MEM_MB:-$((real_mem - alloc_mem))}"
(( MEM_MB > 0 )) || { echo "no free memory reported for ${NODE}" >&2; exit 2; }

mkdir -p "${WORKER_OUT_ROOT}"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/run_serial20.sh" \
  "${VERSION_DIR}/submit_serial20_zzhang510.sh" "${WORKER_OUT_ROOT}/"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p acd_u --nodelist=${NODE} --gres=gpu:2 -c8 --mem=${MEM_MB}M --time=04:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && CUDA_VISIBLE_DEVICES=0,1 INPUTS_FILE=${INPUTS_FILE} WORKER_OUT_ROOT=${WORKER_OUT_ROOT} PORT=${PORT} bash ${VERSION_DIR}/run_serial20.sh\" 2>&1 | tee -a ${WORKER_OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\nnode=%s\nworker_out_root=%s\nmem_mb=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${NODE}" "${WORKER_OUT_ROOT}" "${MEM_MB}"
