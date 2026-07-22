#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${TASK22_V3_DATASET:?set TASK22_V3_DATASET}"
: "${TASK22_V3_DATA_MANIFEST:?set TASK22_V3_DATA_MANIFEST}"
: "${TRAIN_OUTPUT_ROOT:?set TRAIN_OUTPUT_ROOT}"

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
DISPATCH_ROOT="${TRAIN_OUTPUT_ROOT}/task22_v3_dispatch_${STAMP}"
mkdir -p "${DISPATCH_ROOT}"
printf 'status=started\nstarted_at=%s\n' "$(date -Is)" >"${DISPATCH_ROOT}/LIVE_STATUS.txt"

srun -p acd_u --gres=gpu:1 -c2 --mem=8192M --time=00:01:00 --job-name="task22v3probe_${STAMP}" \
  bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null
printf 'slurm_probe=passed\n' >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"

MAX_PER_CPU="$(scontrol show partition acd_u | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p' | head -n1)"
MEM_MB="$(( 16 * ${MAX_PER_CPU:-20480} ))"
run_probe() {
  local batch="$1"
  local port="$2"
  local log="${DISPATCH_ROOT}/probe_bs${batch}.log"
  set +e
  srun -p acd_u --gres=gpu:2 -c16 --mem="${MEM_MB}M" --time=00:15:00 --job-name="task22v3bs${batch}_${STAMP}" \
    bash -lc "cd ${VERSION_DIR} && PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} TASK22_V3_DATASET=${TASK22_V3_DATASET} TASK22_V3_DATA_MANIFEST=${TASK22_V3_DATA_MANIFEST} PROBE_OUTPUT_ROOT=${DISPATCH_ROOT}/probes PROBE_BATCH=${batch} MASTER_PORT=${port} STAMP=${STAMP}_bs${batch} bash ${VERSION_DIR}/probe_one_batch.sh" \
    2>&1 | tee -a "${log}"
  local rc="${PIPESTATUS[0]}"
  set -e
  printf 'probe_bs%s_exit=%s\n' "${batch}" "${rc}" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"
  return "${rc}"
}

if run_probe 4 29624; then
  SELECTED_BS=4
else
  run_probe 2 29625
  SELECTED_BS=2
fi
printf 'selected_per_device_batch=%s\n' "${SELECTED_BS}" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"

RUN_ID="task22_v3_native_boundary_${STAMP}"
OUT_ROOT="${TRAIN_OUTPUT_ROOT}/${RUN_ID}"
cp -p "${VERSION_DIR}/PRE_TRAIN.md" "${VERSION_DIR}/run_train.sh" "${VERSION_DIR}/dispatch_train_after_probe_zzhang510.sh" "${OUT_ROOT}/" 2>/dev/null || true
srun -p acd_u --gres=gpu:2 -c16 --mem="${MEM_MB}M" --time=02:00:00 --job-name="task22v3train_${STAMP}" \
  bash -lc "cd ${VERSION_DIR} && PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE} TASK22_V3_DATASET=${TASK22_V3_DATASET} TASK22_V3_DATA_MANIFEST=${TASK22_V3_DATA_MANIFEST} TRAIN_OUTPUT_ROOT=${TRAIN_OUTPUT_ROOT} RUN_ID=${RUN_ID} PER_DEVICE_BS=${SELECTED_BS} MASTER_PORT=29626 STAMP=${STAMP}_train bash ${VERSION_DIR}/run_train.sh" \
  2>&1 | tee -a "${DISPATCH_ROOT}/train.log"
TRAIN_RC="${PIPESTATUS[0]}"
printf 'train_exit=%s\nfinished_at=%s\n' "${TRAIN_RC}" "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"
exit "${TRAIN_RC}"
