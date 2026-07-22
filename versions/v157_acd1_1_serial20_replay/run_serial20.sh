#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"

: "${INPUTS_FILE:?set INPUTS_FILE to an untracked private environment file}"
: "${WORKER_OUT_ROOT:?set WORKER_OUT_ROOT}"
: "${PORT:?set PORT}"
[[ -f "${INPUTS_FILE}" ]] || { echo "missing ${INPUTS_FILE}" >&2; exit 2; }

REPEATS="${REPEATS:-20}"
FIXED_SEED="${FIXED_SEED:-105}"
MAX_STEPS="${MAX_STEPS:-2000}"
REPLAN_STEPS="${REPLAN_STEPS:-5}"
[[ "${REPEATS}" == "20" ]] || { echo "v157 requires REPEATS=20" >&2; exit 2; }
[[ "${FIXED_SEED}" == "105" ]] || { echo "v157 is fixed to seed105" >&2; exit 2; }

mkdir -p "${WORKER_OUT_ROOT}"
printf 'version=v157\nnode=%s\nrepeats=%s\nfixed_seed=%s\nport=%s\n' \
  "${SLURMD_NODENAME:-unknown}" "${REPEATS}" "${FIXED_SEED}" "${PORT}" \
  > "${WORKER_OUT_ROOT}/worker_manifest.env"
printf 'repeat\tseed\trun_id\treturn_code\tout_root\n' > "${WORKER_OUT_ROOT}/worker_runs.tsv"

for repeat in $(seq 0 19); do
  run_id="task23_v157_fixedseed${FIXED_SEED}_serial_repeat${repeat}"
  episode_out="${WORKER_OUT_ROOT}/repeat${repeat}"
  mkdir -p "${episode_out}"

  set +e
  INPUTS_FILE="${INPUTS_FILE}" \
  RUN_ID="${run_id}" \
  OUT_ROOT="${episode_out}" \
  PORT="${PORT}" \
  NUM_TRIALS=1 \
  SEED="${FIXED_SEED}" \
  MAX_STEPS="${MAX_STEPS}" \
  REPLAN_STEPS="${REPLAN_STEPS}" \
  bash "${PACK_DIR}/run_task23_v155.sh" > "${episode_out}/worker.log" 2>&1
  rc=$?
  set -e

  printf '%s\t%s\t%s\t%s\t%s\n' \
    "${repeat}" "${FIXED_SEED}" "${run_id}" "${rc}" "${episode_out}" \
    >> "${WORKER_OUT_ROOT}/worker_runs.tsv"
  [[ "${rc}" == "0" ]] || {
    echo "Task23 v157 evaluator exited ${rc} at repeat ${repeat}; stopping." >&2
    exit "${rc}"
  }
done
