#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${SEED:?set SEED}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ID="${RUN_ID:-task24_v131frozen_seed${SEED}_${STAMP}}"
OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
SESSION="${SESSION:-task24_v131frozen_${STAMP}_s${SEED}}"
JOB_NAME="${JOB_NAME:-task24v131f_${STAMP}_s${SEED}}"
CPUS_PER_TASK="${CPUS_PER_TASK:-8}"
MAX_MEM_PER_CPU_MB="$(scontrol show partition acd_u | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p')"
MEM_MB="${MEM_MB:-$((CPUS_PER_TASK * MAX_MEM_PER_CPU_MB))}"

mkdir -p "${OUT_ROOT}"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/run_one.sh" "${VERSION_DIR}/submit_one_zzhang510.sh" "${OUT_ROOT}/"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'set -o pipefail; srun -p acd_u --gres=gpu:2 -c${CPUS_PER_TASK} --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} bash -lc \"cd ${VERSION_DIR} && CUDA_VISIBLE_DEVICES=0,1 PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} SEED=${SEED} PORT=${PORT} OUTPUT_ROOT=${OUTPUT_ROOT} RUN_ID=${RUN_ID} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/run_one.sh\" 2>&1 | tee -a ${OUT_ROOT}/submit.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"
printf 'session=%s\njob_name=%s\nout_root=%s\nseed=%s\n' "${SESSION}" "${JOB_NAME}" "${OUT_ROOT}" "${SEED}"
