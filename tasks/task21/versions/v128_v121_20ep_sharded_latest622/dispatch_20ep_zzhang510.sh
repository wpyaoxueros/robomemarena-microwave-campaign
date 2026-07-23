#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
DISPATCH_ROOT="${OUTPUT_ROOT}/task21_v128_dispatch_${STAMP}"
BASE_SEEDS=(100 104 108 112 116)
PORTS=(9820 9821 9822 9823 9824)
mkdir -p "${DISPATCH_ROOT}"
printf 'status=started\nstarted_at=%s\nbase_seeds=%s\n' "$(date -Is)" "${BASE_SEEDS[*]}" >"${DISPATCH_ROOT}/LIVE_STATUS.txt"

srun -p acd_u --gres=gpu:1 -c2 --mem=8192M --time=00:01:00 --job-name="task21v128probe_${STAMP}" \
  bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null
printf 'probe=passed\nprobe_finished=%s\n' "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"

for index in "${!BASE_SEEDS[@]}"; do
  base_seed="${BASE_SEEDS[$index]}"
  port="${PORTS[$index]}"
  run_id="task21_v128_seed${base_seed}_${STAMP}"
  PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
    SEED="${base_seed}" PORT="${port}" OUTPUT_ROOT="${OUTPUT_ROOT}" RUN_ID="${run_id}" \
    OUT_ROOT="${OUTPUT_ROOT}/${run_id}" STAMP="${STAMP}_task21v128_s${base_seed}" \
    SESSION="task21_v128_${STAMP}_s${base_seed}" JOB_NAME="task21v128_${STAMP}_s${base_seed}" \
    MEM_MB=163840 bash "${VERSION_DIR}/submit_shard_zzhang510.sh"
  printf 'submitted_seed_start=%s\n' "${base_seed}" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"
done

printf 'status=submitted\nfinished=%s\n' "$(date -Is)" >>"${DISPATCH_ROOT}/LIVE_STATUS.txt"
