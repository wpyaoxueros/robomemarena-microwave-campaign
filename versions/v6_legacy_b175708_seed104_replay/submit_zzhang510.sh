#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are missing or unreadable" >&2; exit 2; }

STAMP="$(date +%Y%m%d_%H%M%S)"
OUTPUT_ROOT="${OUTPUT_ROOT:-${VERSION_DIR}/outputs}"
RUN_ID="${RUN_ID:-task22_v6_legacy_seed104_${STAMP}}"
OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
SESSION="${SESSION:-task22v6_${STAMP}}"
JOB_NAME="${JOB_NAME:-task22v6_${STAMP}}"
PARTITION="${PARTITION:-acd_u}"
mkdir -p "${OUT_ROOT}"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p ${PARTITION} --gres=gpu:2 -c8 --mem=163840M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} OUTPUT_ROOT=${OUTPUT_ROOT} RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/run_legacy_1ep.sh ${PRIVATE_INPUTS_FILE}\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\nout_root=%s\n' "${SESSION}" "${JOB_NAME}" "${OUT_ROOT}"

