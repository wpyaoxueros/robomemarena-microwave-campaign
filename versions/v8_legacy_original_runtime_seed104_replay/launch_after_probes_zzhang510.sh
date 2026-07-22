#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are missing or unreadable" >&2; exit 2; }

STAMP="$(date +%Y%m%d_%H%M%S)"
RUN_ID="task22_v8_legacy_original_seed104_${STAMP}"
OUT_ROOT="${VERSION_DIR}/outputs/${RUN_ID}"
SESSION="task22v8_${STAMP}"
JOB_NAME="task22v8_${STAMP}"
mkdir -p "${OUT_ROOT}"
[[ -w "${OUT_ROOT}" ]] || { echo "output is not writable" >&2; exit 2; }

select_partition() {
  local partition
  for partition in acd_u acd_ue emergency_acd; do
    if srun --immediate=20 -p "${partition}" --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
      --job-name="task22v8p1_${STAMP}" bash -lc 'echo one_gpu_probe user=$(whoami) host=$(hostname)' \
      > "${OUT_ROOT}/probe_1gpu_${partition}.log" 2>&1; then
      if srun --immediate=20 -p "${partition}" --gres=gpu:2 -c8 --mem=163840M --time=00:02:00 \
        --job-name="task22v8p2_${STAMP}" bash -lc 'echo two_gpu_probe user=$(whoami) host=$(hostname); nvidia-smi --query-gpu=index,uuid --format=csv,noheader' \
        > "${OUT_ROOT}/probe_2gpu_${partition}.log" 2>&1; then
        printf '%s\n' "${partition}" > "${OUT_ROOT}/selected_partition.txt"
        return 0
      fi
    fi
  done
  return 1
}

if ! select_partition; then
  echo 'no partition passed both fresh GPU probes' >&2
  exit 1
fi

PARTITION="$(< "${OUT_ROOT}/selected_partition.txt")"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p ${PARTITION} --gres=gpu:2 -c8 --mem=163840M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} OUTPUT_ROOT=${VERSION_DIR}/outputs RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/run_legacy_1ep.sh ${PRIVATE_INPUTS_FILE}\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\npartition=%s\nout_root=%s\n' "${SESSION}" "${PARTITION}" "${OUT_ROOT}"
