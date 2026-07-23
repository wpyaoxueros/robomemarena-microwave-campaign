#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are missing or unreadable" >&2; exit 2; }
# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"

for required in OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH VLM_CKPT VLA_POLICY VLA_REPO_ID; do
  [[ -r "${!required:-}" ]] || { echo "input is not readable: ${required}" >&2; exit 2; }
done

STAMP="$(date +%Y%m%d_%H%M%S)"
OUTPUT_ROOT="${OUTPUT_ROOT:-${VERSION_DIR}/outputs}"
RUN_ID="${RUN_ID:-task22_v6_legacy_seed104_${STAMP}}"
OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
SESSION="${SESSION:-task22v6_${STAMP}}"
JOB_NAME="${JOB_NAME:-task22v6_${STAMP}}"
mkdir -p "${OUT_ROOT}"
[[ -w "${OUT_ROOT}" ]] || { echo "output is not writable" >&2; exit 2; }

select_partition() {
  local partition mem_per_cpu mem_mb
  for partition in acd_u acd_ue emergency_acd; do
    mem_per_cpu="$(scontrol show partition "${partition}" 2>/dev/null | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p' | head -n 1)"
    mem_mb="$(( ${mem_per_cpu:-20480} * 8 ))"
    if srun --immediate=20 -p "${partition}" --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
      --job-name="task22v6p1_${STAMP}" bash -lc 'echo one_gpu_probe user=$(whoami) host=$(hostname)' \
      > "${OUT_ROOT}/probe_1gpu_${partition}.log" 2>&1; then
      if srun --immediate=20 -p "${partition}" --gres=gpu:2 -c8 --mem="${mem_mb}M" --time=00:02:00 \
        --job-name="task22v6p2_${STAMP}" bash -lc 'echo two_gpu_probe user=$(whoami) host=$(hostname); nvidia-smi --query-gpu=index,uuid --format=csv,noheader' \
        > "${OUT_ROOT}/probe_2gpu_${partition}.log" 2>&1; then
        printf '%s\n' "${partition}" > "${OUT_ROOT}/selected_partition.txt"
        printf '%s\n' "${mem_mb}" > "${OUT_ROOT}/selected_mem_mb.txt"
        return 0
      fi
    fi
  done
  return 1
}

if ! select_partition; then
  echo "no partition passed both fresh GPU probes" >&2
  exit 1
fi

PARTITION="$(< "${OUT_ROOT}/selected_partition.txt")"
MEM_MB="$(< "${OUT_ROOT}/selected_mem_mb.txt")"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p ${PARTITION} --gres=gpu:2 -c8 --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} OUTPUT_ROOT=${OUTPUT_ROOT} RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/run_legacy_1ep.sh ${PRIVATE_INPUTS_FILE}\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\njob_name=%s\npartition=%s\nout_root=%s\n' "${SESSION}" "${JOB_NAME}" "${PARTITION}" "${OUT_ROOT}"
