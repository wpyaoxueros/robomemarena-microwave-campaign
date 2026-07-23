#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUTS_FILE="${INPUTS_FILE:?INPUTS_FILE is required}"
[[ -f "${INPUTS_FILE}" ]] || { echo "missing ${INPUTS_FILE}" >&2; exit 2; }
# shellcheck disable=SC1090
source "${INPUTS_FILE}"

WORKER_ID="${WORKER_ID:?WORKER_ID must be 0..4}"
[[ "${WORKER_ID}" =~ ^[0-4]$ ]] || { echo "WORKER_ID must be 0..4" >&2; exit 2; }
REPEATS="${REPEATS:-4}"
FIXED_SEED="${FIXED_SEED:-105}"
[[ "${REPEATS}" == "4" ]] || { echo "v155 requires REPEATS=4" >&2; exit 2; }
[[ "${FIXED_SEED}" == "105" ]] || { echo "v155 is frozen to FIXED_SEED=105" >&2; exit 2; }

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ID="${RUN_ID:-task23_v155_fixedseed105_${STAMP}_worker${WORKER_ID}}"
OUT_ROOT="${OUT_ROOT:-${OUT_BASE:?OUT_BASE is required}/${RUN_ID}}"
SESSION="${SESSION:-task23_v155_${STAMP}_w${WORKER_ID}}"
JOB_NAME="${JOB_NAME:-task23v155_${STAMP}_w${WORKER_ID}}"
PORT="${PORT:-$((9740 + WORKER_ID))}"
MEM_MB="${MEM_MB:-163840}"
EXCLUDE_NODES="${EXCLUDE_NODES:-}"
EXCLUDE_ARG=()
[[ -n "${EXCLUDE_NODES}" ]] && EXCLUDE_ARG=(--exclude="${EXCLUDE_NODES}")

mkdir -p "${OUT_ROOT}"
cp -p "${ROOT}/run_task23_v155.sh" \
  "${ROOT}/scripts/run_fixed_seed_worker.sh" \
  "${ROOT}/config/release_anchors_task23_v153_no_final_anchor.json" \
  "${ROOT}/history/CHANGE_SPEC_V155.md" \
  "${ROOT}/history/PARENT_V154.md" \
  "${OUT_ROOT}/"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p acd_u --gres=gpu:2 -c8 --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} ${EXCLUDE_ARG[*]} bash -lc \"cd ${ROOT} && INPUTS_FILE=${INPUTS_FILE} WORKER_ID=${WORKER_ID} WORKER_OUT_ROOT=${OUT_ROOT} REPEATS=${REPEATS} FIXED_SEED=${FIXED_SEED} PORT=${PORT} bash ${ROOT}/scripts/run_fixed_seed_worker.sh\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\nout_root=%s\nworker_id=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${OUT_ROOT}" "${WORKER_ID}"
