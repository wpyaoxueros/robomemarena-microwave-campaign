#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${REPO_DIR}/scripts/run_task3_d9_single_gpu_shard.sh"

if [[ "${1:-}" == "--workers" ]]; then
  STAMP="$2"
  LOG_DIR="$3"
  RUNNER="$4"
  for SEED in 106 107 108 109 123; do
    PORT="$((9300 + SEED))"
    RUN_ID="task3_d9_fill_missing5_${STAMP}_seed${SEED}"
    srun -p acd_u -c 8 --gres=gpu:1 --mem=160G \
      --job-name="lhs_t3fill_${SEED}_${STAMP}" \
      env RUN_ID="${RUN_ID}" START_SEED="${SEED}" EPISODE_COUNT=1 PORT="${PORT}" \
      bash "${RUNNER}" >"${LOG_DIR}/seed${SEED}.log" 2>&1 &
  done
  wait
  exit 0
fi

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
LOG_DIR="${REPO_DIR}/evidence/task3_d9_fill_missing5_${STAMP}"
SESSION="lhs_t3_fill5_${STAMP}"

[[ -x "${RUNNER}" ]] || { echo "missing runner: ${RUNNER}" >&2; exit 2; }
mkdir -p "${LOG_DIR}"

tmux -f /dev/null new-session -d -s "${SESSION}" \
  "bash '${BASH_SOURCE[0]}' --workers '${STAMP}' '${LOG_DIR}' '${RUNNER}'"

echo "session=${SESSION}"
echo "log_dir=${LOG_DIR}"
