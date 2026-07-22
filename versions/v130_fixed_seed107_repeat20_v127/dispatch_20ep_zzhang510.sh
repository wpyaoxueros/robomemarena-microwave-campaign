#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are unreadable" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
FIXED_SEED=107
REPEATS=4
BASE_PORTS=(9900 9920 9940 9960 9980)
PARTITIONS=(acd_u acd_ue emergency_acd)
BATCH_ROOT="${OUTPUT_ROOT}/task21_v130_fixedseed107_repeat20_${STAMP}"
mkdir -p "${BATCH_ROOT}"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/run_worker.sh" \
  "${VERSION_DIR}/validate_episode.py" "${VERSION_DIR}/submit_worker_zzhang510.sh" \
  "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" "${VERSION_DIR}/aggregate_fixedseed20.py" "${BATCH_ROOT}/"
printf 'status=started\nstarted_at=%s\nfixed_seed=%s\nworkers=5\nrepeats_per_worker=%s\n' \
  "$(date -Is)" "${FIXED_SEED}" "${REPEATS}" >"${BATCH_ROOT}/LIVE_STATUS.txt"

PARTITION=""
for candidate in "${PARTITIONS[@]}"; do
  if srun --immediate=20 -p "${candidate}" --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
    --job-name="task21v130probe_${STAMP}" bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null; then
    PARTITION="${candidate}"
    break
  fi
done
[[ -n "${PARTITION}" ]] || { echo "no borrowed-account GPU probe succeeded" >&2; exit 3; }
printf 'probe=passed\npartition=%s\nprobe_finished=%s\n' "${PARTITION}" "$(date -Is)" >>"${BATCH_ROOT}/LIVE_STATUS.txt"

for worker_id in 0 1 2 3 4; do
  base_port="${BASE_PORTS[$worker_id]}"
  PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
    BATCH_ROOT="${BATCH_ROOT}" \
    WORKER_ID="${worker_id}" \
    BASE_PORT="${base_port}" \
    FIXED_SEED=107 \
    REPEATS="${REPEATS}" \
    STAMP="${STAMP}_w${worker_id}" \
    PARTITION="${PARTITION}" \
    SESSION="task21_v130_${STAMP}_w${worker_id}" \
    JOB_NAME="task21v130_${STAMP}_w${worker_id}" \
    bash "${VERSION_DIR}/submit_worker_zzhang510.sh" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
done

printf 'status=submitted\nfinished_at=%s\n' "$(date -Is)" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
printf '%s\n' "${BATCH_ROOT}"
