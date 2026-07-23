#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:-${VERSION_DIR}/inputs.env}"
REMOTE_ROOT_OVERRIDE="${ROBOMEMARENA_REMOTE_ROOT_OVERRIDE:?set ROBOMEMARENA_REMOTE_ROOT_OVERRIDE before submitting}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }
PRIVATE_INPUTS_FILE="$(readlink -f "${PRIVATE_INPUTS_FILE}")"
# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_ROOT="${VERSION_DIR}/outputs/seed_state_smoke_${STAMP}"
SESSION="task22v22seed_${STAMP}"
JOB_NAME="task22v22seed_${STAMP}"
mkdir -p "${OUT_ROOT}"

EXCLUDE_ARGS=()
if [[ -n "${SLURM_EXCLUDE_NODES:-}" ]]; then
  EXCLUDE_ARGS+=("--exclude=${SLURM_EXCLUDE_NODES}")
fi

selected_partition=""
for partition in acd_u acd_ue emergency_acd; do
  if srun --immediate=20 -p "${partition}" "${EXCLUDE_ARGS[@]}" --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
    --job-name="task22v22seed_probe_${STAMP}" bash -lc 'whoami; hostname; nvidia-smi -L' \
    >"${OUT_ROOT}/${partition}_1gpu_probe.log" 2>&1; then
    selected_partition="${partition}"
    break
  fi
done

if [[ -z "${selected_partition}" ]]; then
  selected_partition=emergency_acd
  printf 'no immediate 1-GPU allocation; queueing smoke on %s\n' "${selected_partition}" \
    >"${OUT_ROOT}/queue_fallback.log"
fi

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p ${selected_partition} ${EXCLUDE_ARGS[*]:-} --gres=gpu:1 -c4 --mem=81920M --time=00:15:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && ROBOMEMARENA_REMOTE_ROOT_OVERRIDE=${REMOTE_ROOT_OVERRIDE} TARGET_LIBERO_PATH=${TARGET_LIBERO_PATH} OPENPI_ROOT=${OPENPI_ROOT} ${INFER_ROOT}/.venv/bin/python ${VERSION_DIR}/smoke_task22_initial_state.py --remote-root ${REMOTE_ROOT_OVERRIDE} --libero-root ${TARGET_LIBERO_PATH} --output ${OUT_ROOT}/initial_state_report.json\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\nout_root=%s\npartition=%s\n' "${SESSION}" "${OUT_ROOT}" "${selected_partition}"
