#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
PRIVATE_INPUTS_FILE="${1:-${VERSION_DIR}/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }

STAMP="$(date +%Y%m%d_%H%M%S)"
RUN_ID="task22_v14_remote35999_seed104_${STAMP}"
OUT_ROOT="${VERSION_DIR}/outputs/${RUN_ID}"
SESSION="task22v14_${STAMP}"
JOB_NAME="task22v14_${STAMP}"
PARTITION="${PARTITION:-acd_u}"
mkdir -p "${OUT_ROOT}"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p ${PARTITION} --gres=gpu:2 -c8 --mem=163840M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && ROBOMEMARENA_REMOTE_ROOT_OVERRIDE=${ROBOMEMARENA_REMOTE_ROOT_OVERRIDE} RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/run_1ep.sh ${PRIVATE_INPUTS_FILE}\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\nout_root=%s\npartition=%s\n' "${SESSION}" "${OUT_ROOT}" "${PARTITION}"
