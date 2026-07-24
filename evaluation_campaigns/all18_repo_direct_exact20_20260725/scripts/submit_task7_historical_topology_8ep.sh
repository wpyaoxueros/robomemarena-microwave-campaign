#!/usr/bin/env bash
set -euo pipefail

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${CAMPAIGN_DIR}/scripts/run_task7_historical_topology_8ep.sh"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}
MEM_MB=${MEM_MB:-163840}
TIME_LIMIT=${TIME_LIMIT:-02:00:00}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task7_historical_topology_8ep_${STAMP}}
SESSION=${SESSION:-lhs_task7_reference_${STAMP}}
JOB_NAME=${JOB_NAME:-lhs_task7_reference_${STAMP}}
PORT=${PORT:-29707}
LOG_DIR="${OUTPUT_ROOT}/launcher_logs"
LOG_FILE="${LOG_DIR}/${SESSION}.log"

[[ -x "$(command -v tmux)" ]] || { echo "tmux is required" >&2; exit 2; }
[[ -x "${RUNNER}" ]] || { echo "missing runner: ${RUNNER}" >&2; exit 2; }
mkdir -p "${LOG_DIR}"

tmux -f /dev/null new-session -d -s "${SESSION}" \
  "bash -lc 'srun -p acd_u --gres=gpu:2 -c16 --mem=${MEM_MB}M --time=${TIME_LIMIT} --job-name=${JOB_NAME} env OUTPUT_ROOT=${OUTPUT_ROOT} RUN_ID=${RUN_ID} PORT=${PORT} bash ${RUNNER} >>${LOG_FILE} 2>&1; rc=\$?; printf \"[TMUX_EXIT] status=%s\\n\" \"\$rc\" >>${LOG_FILE}; exec bash'"

printf 'session=%s\njob_name=%s\nrun_id=%s\nlog=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${RUN_ID}" "${LOG_FILE}"
