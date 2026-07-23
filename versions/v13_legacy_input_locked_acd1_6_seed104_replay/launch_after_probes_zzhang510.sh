#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "historical inputs are unreadable" >&2; exit 2; }

STAMP="$(date +%Y%m%d_%H%M%S)"
RUN_ID="task22_v13_historical_locked_seed104_${STAMP}"
OUT_ROOT="${VERSION_DIR}/outputs/${RUN_ID}"
SESSION="task22v13_${STAMP}"
JOB_NAME="task22v13_${STAMP}"
PORT=19722
mkdir -p "${OUT_ROOT}"
[[ -w "${OUT_ROOT}" ]] || { echo "output is not writable" >&2; exit 2; }

"${VERSION_DIR}/verify_historical_inputs.sh" "${PRIVATE_INPUTS_FILE}" > "${OUT_ROOT}/preflight_inputs.log"

srun --immediate=20 -p emergency_acd --nodelist=ACD1-6 --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
  --job-name="task22v13p1_${STAMP}" bash -lc 'echo probe_1gpu user=$(whoami) host=$(hostname)' \
  > "${OUT_ROOT}/probe_1gpu.log" 2>&1
srun --immediate=20 -p emergency_acd --nodelist=ACD1-6 --gres=gpu:2 -c8 --mem=163840M --time=00:02:00 \
  --job-name="task22v13p2_${STAMP}" bash -lc 'echo probe_2gpu user=$(whoami) host=$(hostname); nvidia-smi --query-gpu=index,uuid --format=csv,noheader' \
  > "${OUT_ROOT}/probe_2gpu.log" 2>&1

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p emergency_acd --nodelist=ACD1-6 --gres=gpu:2 -c8 --mem=163840M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && OUT_ROOT=${OUT_ROOT} RUN_ID=${RUN_ID} PORT=${PORT} bash ${VERSION_DIR}/run_inside_allocation_zzhang510.sh ${PRIVATE_INPUTS_FILE}\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\nout_root=%s\nport=%s\n' "${SESSION}" "${OUT_ROOT}" "${PORT}"
