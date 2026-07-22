#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_VERSION_DIR="${VERSION_DIR}/../v6_legacy_b175708_seed104_replay"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are missing or unreadable" >&2; exit 2; }
[[ -x "${BASE_VERSION_DIR}/run_legacy_1ep.sh" ]] || { echo "base runtime is missing" >&2; exit 2; }

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
OUT_ROOT="${OUT_ROOT:-${VERSION_DIR}/outputs/task22_v7_legacy_seed104_acd1_6_${STAMP}}"
NODE="ACD1-6"
PARTITION="acd_ue"
MEM_MB=163840
mkdir -p "${OUT_ROOT}"
[[ -w "${OUT_ROOT}" ]] || { echo "output is not writable" >&2; exit 2; }

attempt=0
while true; do
  attempt=$((attempt + 1))
  printf 'attempt=%s timestamp=%s node=%s\n' "${attempt}" "$(date -Is)" "${NODE}" | tee -a "${OUT_ROOT}/node_watch.log"

  if srun --immediate=20 -p "${PARTITION}" --nodelist="${NODE}" --gres=gpu:1 \
    -c1 --mem=1024M --time=00:01:00 --job-name="task22v7p1_${STAMP}" \
    bash -lc 'echo one_gpu_probe user=$(whoami) host=$(hostname); nvidia-smi --query-gpu=index,uuid --format=csv,noheader' \
    > "${OUT_ROOT}/probe_1gpu_attempt${attempt}.log" 2>&1; then
    if srun --immediate=20 -p "${PARTITION}" --nodelist="${NODE}" --gres=gpu:2 \
      -c8 --mem="${MEM_MB}M" --time=00:02:00 --job-name="task22v7p2_${STAMP}" \
      bash -lc 'echo two_gpu_probe user=$(whoami) host=$(hostname); nvidia-smi --query-gpu=index,uuid --format=csv,noheader' \
      > "${OUT_ROOT}/probe_2gpu_attempt${attempt}.log" 2>&1; then
      printf 'node=%s\npartition=%s\nmem_mb=%s\n' "${NODE}" "${PARTITION}" "${MEM_MB}" > "${OUT_ROOT}/launch_contract.tsv"
      srun -p "${PARTITION}" --nodelist="${NODE}" --gres=gpu:2 -c8 --mem="${MEM_MB}M" --time=02:00:00 \
        --job-name="task22v7_${STAMP}" \
        bash -lc "cd '${BASE_VERSION_DIR}' && PRIVATE_INPUTS_FILE='${PRIVATE_INPUTS_FILE}' OUTPUT_ROOT='${VERSION_DIR}/outputs' RUN_ID='task22_v7_legacy_seed104_acd1_6_${STAMP}' OUT_ROOT='${OUT_ROOT}' bash '${BASE_VERSION_DIR}/run_legacy_1ep.sh' '${PRIVATE_INPUTS_FILE}'" \
        2>&1 | tee -a "${OUT_ROOT}/submit.log"
      exit "${PIPESTATUS[0]}"
    fi
  fi

  sleep 60
done
