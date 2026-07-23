#!/usr/bin/env bash
set -euo pipefail

[[ "$#" == "1" ]] || { echo "usage: $0 <runtime-env>" >&2; exit 2; }
RUNTIME_ENV="$1"
[[ -r "${RUNTIME_ENV}" ]] || { echo "missing runtime env: ${RUNTIME_ENV}" >&2; exit 2; }

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
V127_RUNNER="${PACK_DIR}/versions/v127_single_seed107_serial_replay/run_one.sh"

: "${PRIVATE_INPUTS_FILE:?}"
: "${BATCH_ROOT:?}"
: "${WORKER_ID:?}"
: "${BASE_PORT:?}"
FIXED_SEED="${FIXED_SEED:-107}"
REPEATS="${REPEATS:-4}"
[[ "${FIXED_SEED}" == "107" ]] || { echo "v130 is fixed to seed107" >&2; exit 2; }
[[ "${WORKER_ID}" =~ ^[0-4]$ ]] || { echo "WORKER_ID must be 0..4" >&2; exit 2; }
[[ "${REPEATS}" == "4" ]] || { echo "v130 requires four attempts per worker" >&2; exit 2; }
[[ -f "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }
[[ -x "${V127_RUNNER}" || -f "${V127_RUNNER}" ]] || { echo "missing v127 runner" >&2; exit 2; }

WORKER_ROOT="${BATCH_ROOT}/worker${WORKER_ID}"
mkdir -p "${WORKER_ROOT}"
printf 'global_episode\tworker_id\trepeat\tseed\trun_id\texit_code\tvalidation_valid\tstage_score_pct\tstage_success\tgoal_success\trun_dir\n' >"${WORKER_ROOT}/attempts.tsv"
printf 'status=running\nworker_id=%s\nfixed_seed=%s\nrepeats=%s\nstarted_at=%s\n' \
  "${WORKER_ID}" "${FIXED_SEED}" "${REPEATS}" "$(date -Is)" >"${WORKER_ROOT}/LIVE_STATUS.txt"

for repeat in 0 1 2 3; do
  global_episode=$((WORKER_ID * REPEATS + repeat))
  attempt_root="${WORKER_ROOT}/episode$(printf '%03d' "${global_episode}")"
  run_id="task21_v130_seed107_w${WORKER_ID}_e${global_episode}_$(date +%Y%m%d_%H%M%S)"
  run_dir="${attempt_root}/${run_id}"
  port=$((BASE_PORT + repeat))
  mkdir -p "${attempt_root}"
  printf 'status=running\nworker_id=%s\nglobal_episode=%s\nrepeat=%s\nfixed_seed=%s\nrun_id=%s\nstarted_at=%s\n' \
    "${WORKER_ID}" "${global_episode}" "${repeat}" "${FIXED_SEED}" "${run_id}" "$(date -Is)" >"${WORKER_ROOT}/LIVE_STATUS.txt"

  set +e
  PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
    PORT="${port}" \
    OUTPUT_ROOT="${attempt_root}" \
    RUN_ID="${run_id}" \
    OUT_ROOT="${run_dir}" \
    SEED="${FIXED_SEED}" \
    NUM_TRIALS=1 \
    STAMP="$(date +%Y%m%d_%H%M%S)_v130_w${WORKER_ID}_e${global_episode}" \
    bash "${V127_RUNNER}" >"${attempt_root}/worker.log" 2>&1
  run_rc=$?
  python3 "${VERSION_DIR}/validate_episode.py" "${run_dir}" "${FIXED_SEED}" >"${attempt_root}/validation.json"
  validation_rc=$?
  set -e

  readarray -t record < <(python3 - "${attempt_root}/validation.json" "${validation_rc}" <<'PY'
import json
import sys

record = json.load(open(sys.argv[1], encoding="utf-8"))
valid = int(bool(record.get("valid")) and int(sys.argv[2]) == 0)
print(valid)
print(record.get("stage_score_pct", ""))
print("Y" if record.get("stage_success") else "N")
print("Y" if record.get("goal_success") else "N")
print(record.get("run_dir", ""))
PY
)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "${global_episode}" "${WORKER_ID}" "${repeat}" "${FIXED_SEED}" "${run_id}" "${run_rc}" \
    "${record[0]}" "${record[1]}" "${record[2]}" "${record[3]}" "${record[4]}" >>"${WORKER_ROOT}/attempts.tsv"
  printf 'status=attempt_finished\nworker_id=%s\nglobal_episode=%s\nrepeat=%s\nfixed_seed=%s\nexit_code=%s\nvalidation_valid=%s\nfinished_at=%s\n' \
    "${WORKER_ID}" "${global_episode}" "${repeat}" "${FIXED_SEED}" "${run_rc}" "${record[0]}" "$(date -Is)" >"${WORKER_ROOT}/LIVE_STATUS.txt"
done

printf 'status=complete\nworker_id=%s\nfixed_seed=%s\nattempts=%s\nfinished_at=%s\n' \
  "${WORKER_ID}" "${FIXED_SEED}" "${REPEATS}" "$(date -Is)" >"${WORKER_ROOT}/LIVE_STATUS.txt"
touch "${WORKER_ROOT}/COMPLETE"
