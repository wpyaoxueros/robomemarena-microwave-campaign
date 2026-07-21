#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUTS_FILE="${INPUTS_FILE:-${ROOT}/inputs.env}"
[[ -f "${INPUTS_FILE}" ]] || { echo "missing ${INPUTS_FILE}" >&2; exit 2; }
# shellcheck disable=SC1090
source "${INPUTS_FILE}"

OUT_BASE=${OUT_BASE:?OUT_BASE is required in inputs.env}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task23_v148_${STAMP}}
OUT_ROOT=${OUT_ROOT:-${OUT_BASE}/${RUN_ID}}
SESSION=${SESSION:-task23_v148_${STAMP}}
JOB_NAME=${JOB_NAME:-task23v148_${STAMP}}
PORT=${PORT:-9723}
MEM_MB=${MEM_MB:-163840}
EXCLUDE_NODES=${EXCLUDE_NODES:-}
EXCLUDE_ARG=()
[[ -n "${EXCLUDE_NODES}" ]] && EXCLUDE_ARG=(--exclude="${EXCLUDE_NODES}")

mkdir -p "${OUT_ROOT}"
cp -p "${ROOT}/run_task23_v148.sh" "${ROOT}/inputs.env.example" \
  "${ROOT}/config/release_anchors_task23_v145_remove_cream_place_anchor.json" \
  "${ROOT}/history/HYPOTHESIS.md" "${ROOT}/runtime_assets/ORIGINAL_NORM.md" "${OUT_ROOT}/"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p acd_u --gres=gpu:2 -c8 --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} ${EXCLUDE_ARG[*]} bash -lc \"cd ${ROOT} && INPUTS_FILE=${INPUTS_FILE} RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} PORT=${PORT} bash ${ROOT}/run_task23_v148.sh\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\nout_root=%s\n' "${SESSION}" "${JOB_NAME}" "${OUT_ROOT}"
