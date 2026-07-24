#!/usr/bin/env bash
set -euo pipefail

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${CAMPAIGN_DIR}/scripts/run_task21_d9_direct20_single_gpu.sh"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}
MEM_MB=${MEM_MB:-131072}
TIME_LIMIT=${TIME_LIMIT:-08:00:00}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task21_all18_d9_direct20_single_gpu_${STAMP}}
SESSION=${SESSION:-lhs_task21_d9_direct20_${STAMP}}
JOB_NAME=${JOB_NAME:-lhs_task21_d9_direct20_${STAMP}}
LOG_DIR="${OUTPUT_ROOT}/launcher_logs"
LOG_FILE="${LOG_DIR}/${SESSION}.log"

[[ -x "$(command -v tmux)" ]] || { echo "tmux is required" >&2; exit 2; }
[[ -f "${RUNNER}" ]] || { echo "missing runner: ${RUNNER}" >&2; exit 2; }
mkdir -p "${LOG_DIR}"

tmux -f /dev/null new-session -d -s "${SESSION}" \
  "bash -lc 'srun -p acd_u --gres=gpu:1 -c8 --mem=${MEM_MB}M --time=${TIME_LIMIT} --job-name=${JOB_NAME} env OUTPUT_ROOT=${OUTPUT_ROOT} RUN_ID=${RUN_ID} bash ${RUNNER} >>${LOG_FILE} 2>&1; rc=\$?; printf \"[TMUX_EXIT] status=%s\\n\" \"\$rc\" >>${LOG_FILE}; exec bash'"

printf 'session=%s\njob_name=%s\nrun_id=%s\nlog=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${RUN_ID}" "${LOG_FILE}"
