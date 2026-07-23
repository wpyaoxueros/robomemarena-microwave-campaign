#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
PRIVATE_INPUTS_FILE="${1:-${VERSION_DIR}/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }
PRIVATE_INPUTS_FILE="$(readlink -f "${PRIVATE_INPUTS_FILE}")"

STAMP="$(date +%Y%m%d_%H%M%S)"
RUN_ID="task22_v22_35999_stageprompt_openpickcookies_robotanchors_vlm150_seed104_${STAMP}"
OUT_ROOT="${VERSION_DIR}/outputs/${RUN_ID}"
SESSION="task22v22_${STAMP}"
JOB_NAME="task22v22_${STAMP}"
PARTITION="${PARTITION:-acd_u}"
EXCLUDE_ARG=""
if [[ -n "${SLURM_EXCLUDE_NODES:-}" ]]; then
  EXCLUDE_ARG="--exclude=${SLURM_EXCLUDE_NODES}"
fi
mkdir -p "${OUT_ROOT}"

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p ${PARTITION} ${EXCLUDE_ARG} --gres=gpu:2 -c8 --mem=163840M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && ROBOMEMARENA_REMOTE_ROOT_OVERRIDE=${ROBOMEMARENA_REMOTE_ROOT_OVERRIDE} SLURM_EXCLUDE_NODES=${SLURM_EXCLUDE_NODES:-} RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/run_1ep.sh ${PRIVATE_INPUTS_FILE}\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\nout_root=%s\npartition=%s\nexclude_nodes=%s\n' "${SESSION}" "${OUT_ROOT}" "${PARTITION}" "${SLURM_EXCLUDE_NODES:-}"
