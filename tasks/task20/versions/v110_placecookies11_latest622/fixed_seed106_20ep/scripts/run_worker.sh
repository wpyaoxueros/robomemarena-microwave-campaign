#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
BATCH_ROOT=${BATCH_ROOT:?BATCH_ROOT is required}
WORKER_ID=${WORKER_ID:?WORKER_ID is required}
FIXED_SEED=${FIXED_SEED:-106}
REPEATS=${REPEATS:-4}
MAX_ATTEMPTS=${MAX_ATTEMPTS:-3}
NORM_REPO=${VLA_REPO_ID:-${PACK_DIR}/assets/norm_repo}
RUNNER=${V110_RUNNER:-${PACK_DIR}/scripts/run_task20_v110.sh}

[[ "${WORKER_ID}" =~ ^[0-4]$ ]] || { echo "WORKER_ID must be 0..4" >&2; exit 2; }
[[ "${REPEATS}" == "4" ]] || { echo "REPEATS must be 4" >&2; exit 2; }
[[ -x "${RUNNER}" ]] || { echo "missing v110 runner: ${RUNNER}" >&2; exit 3; }

WORKER_ROOT="${BATCH_ROOT}/worker${WORKER_ID}"
mkdir -p "${WORKER_ROOT}"
printf 'episode\tseed\trepeat\tattempt\trc\tvalid\trun_dir\n' >"${WORKER_ROOT}/attempts.tsv"

for ((repeat = 0; repeat < REPEATS; repeat++)); do
  episode=$((WORKER_ID * REPEATS + repeat))
  valid=0
  for ((attempt = 0; attempt < MAX_ATTEMPTS; attempt++)); do
    stamp="$(date +%Y%m%d_%H%M%S)"
    run_id="task20_v110_seed${FIXED_SEED}_ep${episode}_w${WORKER_ID}_a${attempt}_${stamp}"
    attempt_root="${WORKER_ROOT}/episode$(printf '%03d' "${episode}")/attempt${attempt}"
    run_dir="${attempt_root}/${run_id}"
    mkdir -p "${attempt_root}"

    set +e
    OUTPUT_ROOT="${attempt_root}" \
    RUN_ID="${run_id}" \
    SEED="${FIXED_SEED}" \
    NUM_TRIALS=1 \
    MAX_STEPS=1000 \
    REPLAN_STEPS=10 \
    VLA_REPO_ID="${NORM_REPO}" \
      /bin/bash "${RUNNER}" >"${attempt_root}/worker.log" 2>&1
    rc=$?
    set -e

    if [[ "${rc}" -eq 0 ]] && python "${SCRIPT_DIR}/validate_episode.py" "${run_dir}" \
      >"${attempt_root}/validation.json" 2>"${attempt_root}/validation.err"; then
      valid=1
      printf '%s\n' "${run_dir}" \
        >"${WORKER_ROOT}/episode$(printf '%03d' "${episode}")/valid_run.txt"
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "${episode}" "${FIXED_SEED}" "${repeat}" "${attempt}" "${rc}" "${valid}" "${run_dir}" \
      >>"${WORKER_ROOT}/attempts.tsv"
    [[ "${valid}" -eq 1 ]] && break
    sleep 3
  done
  [[ "${valid}" -eq 1 ]] || { echo "episode ${episode} is invalid" >&2; exit 4; }
done

touch "${WORKER_ROOT}/COMPLETE"
