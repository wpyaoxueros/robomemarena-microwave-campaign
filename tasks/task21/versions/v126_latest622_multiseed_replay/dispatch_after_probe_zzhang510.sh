#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
DISPATCH_ROOT="${OUTPUT_ROOT}/task21_v126_dispatch_${STAMP}"
mkdir -p "${DISPATCH_ROOT}"

printf 'dispatch_started=%s\n' "$(date -Is)" >"${DISPATCH_ROOT}/LIVE_STATUS.txt"
srun -p acd_u --gres=gpu:1 -c2 --mem=8192M --time=00:01:00 --job-name="task21v126probe_${STAMP}" \
  bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null
printf 'probe=passed\nprobe_finished=%s\n' "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"

for spec in '107 9801' '108 9802' '109 9803'; do
  set -- ${spec}
  seed="$1"
  port="$2"
  run_id="task21_v126_seed${seed}_${STAMP}"
  PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
    SEED="${seed}" PORT="${port}" OUTPUT_ROOT="${OUTPUT_ROOT}" RUN_ID="${run_id}" \
    OUT_ROOT="${OUTPUT_ROOT}/${run_id}" STAMP="${STAMP}_task21v126_s${seed}" \
    SESSION="task21_v126_${STAMP}_s${seed}" JOB_NAME="task21v126_${STAMP}_s${seed}" \
    MEM_MB=163840 bash "${VERSION_DIR}/submit_one_zzhang510.sh"
done

printf 'submissions=created\nfinished=%s\n' "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"
