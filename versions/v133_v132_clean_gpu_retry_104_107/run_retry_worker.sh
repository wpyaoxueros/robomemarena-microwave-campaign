#!/usr/bin/env bash
set -euo pipefail

[[ "$#" == "1" ]] || { echo "usage: $0 <runtime-env>" >&2; exit 2; }
RUNTIME_ENV="$1"
[[ -r "${RUNTIME_ENV}" ]] || { echo "missing runtime env: ${RUNTIME_ENV}" >&2; exit 2; }

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_VERSION_DIR="${VERSION_DIR}/../v132_v131_multiseed20_five_nodes"
RUN_ONE="${SOURCE_VERSION_DIR}/run_one.sh"
VALIDATE="${SOURCE_VERSION_DIR}/validate_episode.py"

: "${PRIVATE_INPUTS_FILE:?}"
: "${BATCH_ROOT:?}"
: "${WORKER_ID:?}"
: "${RETRY_SEED:?}"
: "${BASE_PORT:?}"
GPU_PREFLIGHT_MAX_MIB="${GPU_PREFLIGHT_MAX_MIB:-4096}"

[[ "${WORKER_ID}" =~ ^[0-3]$ ]] || { echo "WORKER_ID must be 0..3" >&2; exit 2; }
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }
[[ -x "${RUN_ONE}" && -f "${VALIDATE}" ]] || { echo "missing frozen v132 entrypoint" >&2; exit 2; }

WORKER_ROOT="${BATCH_ROOT}/worker${WORKER_ID}"
mkdir -p "${WORKER_ROOT}"
printf 'global_episode\tworker_id\tlocal_episode\tseed\trun_id\texit_code\tvalidation_valid\tstage_score_pct\tstage_success\tgoal_success\trun_dir\n' >"${WORKER_ROOT}/attempts.tsv"
printf 'status=running\nworker_id=%s\nseed=%s\nstarted_at=%s\n' \
  "${WORKER_ID}" "${RETRY_SEED}" "$(date -Is)" >"${WORKER_ROOT}/LIVE_STATUS.txt"

# A stale foreign process is an infrastructure fault, not an evaluation outcome.
nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv,noheader,nounits >"${WORKER_ROOT}/gpu_preflight.tsv"
if ! awk -F, -v limit="${GPU_PREFLIGHT_MAX_MIB}" '
  {
    used = $2
    gsub(/[^0-9]/, "", used)
    if ((used + 0) > limit) {
      exit 1
    }
  }
' "${WORKER_ROOT}/gpu_preflight.tsv"; then
  printf '%s\t%s\t0\t%s\tpreflight_gpu_busy\t42\t0\t\tN\tN\t\n' \
    "$((RETRY_SEED - 104))" "${WORKER_ID}" "${RETRY_SEED}" >>"${WORKER_ROOT}/attempts.tsv"
  printf 'status=invalid_gpu_preflight\nworker_id=%s\nseed=%s\nfinished_at=%s\n' \
    "${WORKER_ID}" "${RETRY_SEED}" "$(date -Is)" >"${WORKER_ROOT}/LIVE_STATUS.txt"
  touch "${WORKER_ROOT}/COMPLETE"
  exit 42
fi

attempt_root="${WORKER_ROOT}/episode$(printf '%03d' "$((RETRY_SEED - 104))")"
run_id="task24_v133_seed${RETRY_SEED}_retry_w${WORKER_ID}_$(date +%Y%m%d_%H%M%S)"
run_dir="${attempt_root}/${run_id}"
mkdir -p "${attempt_root}"

set +e
PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
  PORT="${BASE_PORT}" \
  OUTPUT_ROOT="${attempt_root}" \
  RUN_ID="${run_id}" \
  OUT_ROOT="${run_dir}" \
  SEED="${RETRY_SEED}" \
  NUM_TRIALS=1 \
  STAMP="$(date +%Y%m%d_%H%M%S)_v133_w${WORKER_ID}" \
  bash "${RUN_ONE}" >"${attempt_root}/worker.log" 2>&1
run_rc=$?
python3 "${VALIDATE}" "${run_dir}" "${RETRY_SEED}" >"${attempt_root}/validation.json"
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
printf '%s\t%s\t0\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$((RETRY_SEED - 104))" "${WORKER_ID}" "${RETRY_SEED}" "${run_id}" "${run_rc}" \
  "${record[0]}" "${record[1]}" "${record[2]}" "${record[3]}" "${record[4]}" >>"${WORKER_ROOT}/attempts.tsv"
printf 'status=complete\nworker_id=%s\nseed=%s\nexit_code=%s\nvalidation_valid=%s\nfinished_at=%s\n' \
  "${WORKER_ID}" "${RETRY_SEED}" "${run_rc}" "${record[0]}" "$(date -Is)" >"${WORKER_ROOT}/LIVE_STATUS.txt"
touch "${WORKER_ROOT}/COMPLETE"
