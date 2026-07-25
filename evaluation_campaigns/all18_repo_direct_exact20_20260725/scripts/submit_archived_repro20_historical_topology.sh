#!/usr/bin/env bash
set -euo pipefail

TASK_ID=${1:?usage: submit_archived_repro20_historical_topology.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
RUNNER="${CAMPAIGN_DIR}/scripts/run_archived_repro20_historical_topology.sh"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}
PARTITION=${PARTITION:-acd_u}
CAMPAIGN_GIT_COMMIT=${CAMPAIGN_GIT_COMMIT:-$(git -c safe.directory="${REPO_DIR}" -C "${REPO_DIR}" rev-parse HEAD)}
MEM_MB=${MEM_MB:-327680}
TIME_LIMIT=${TIME_LIMIT:-10:00:00}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task${TASK_ID}_historical66e789_exact20_${STAMP}}
SESSION=${SESSION:-lhs_t${TASK_ID}_historical66e789_${STAMP}}
JOB_NAME=${JOB_NAME:-lhs_t${TASK_ID}_historical66e789_${STAMP}}
LOG_DIR="${OUTPUT_ROOT}/launcher_logs"
LOG_FILE="${LOG_DIR}/${SESSION}.log"

[[ -x "$(command -v tmux)" ]] || { echo "tmux is required" >&2; exit 2; }
[[ -x "${RUNNER}" ]] || { echo "missing runner: ${RUNNER}" >&2; exit 2; }
mkdir -p "${LOG_DIR}"

tmux -f /dev/null new-session -d -s "${SESSION}" \
  "bash -lc 'srun -p \"${PARTITION}\" --gres=gpu:2 -c16 --mem=${MEM_MB}M --time=${TIME_LIMIT} --job-name=${JOB_NAME} env OUTPUT_ROOT=${OUTPUT_ROOT} RUN_ID=${RUN_ID} CAMPAIGN_GIT_COMMIT=${CAMPAIGN_GIT_COMMIT} bash ${RUNNER} ${TASK_ID} >>${LOG_FILE} 2>&1; rc=\$?; printf \"[TMUX_EXIT] status=%s\\n\" \"\$rc\" >>${LOG_FILE}; exec bash'"

printf 'session=%s\njob_name=%s\nrun_id=%s\npartition=%s\nlog=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${RUN_ID}" "${PARTITION}" "${LOG_FILE}"
