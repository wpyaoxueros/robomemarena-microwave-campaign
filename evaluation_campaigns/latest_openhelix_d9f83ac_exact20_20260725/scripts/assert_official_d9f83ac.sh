#!/usr/bin/env bash
set -euo pipefail

OFFICIAL_ROOT=${1:?usage: assert_official_d9f83ac.sh OFFICIAL_ROOT}
EXPECTED_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
EXPECTED_STAGE_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538
STAGE_FILE="${OFFICIAL_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py"

[[ -d "${OFFICIAL_ROOT}/.git" ]] || {
  echo "[ERROR] official root is not a git checkout: ${OFFICIAL_ROOT}" >&2
  exit 2
}

actual_commit="$(git -C "${OFFICIAL_ROOT}" rev-parse HEAD)"
[[ "${actual_commit}" == "${EXPECTED_COMMIT}" ]] || {
  echo "[ERROR] official commit mismatch: expected=${EXPECTED_COMMIT} actual=${actual_commit}" >&2
  exit 3
}

[[ -f "${STAGE_FILE}" ]] || {
  echo "[ERROR] required current stage scorer is absent: ${STAGE_FILE}" >&2
  exit 4
}

actual_stage_sha="$(sha256sum "${STAGE_FILE}" | awk '{print $1}')"
[[ "${actual_stage_sha}" == "${EXPECTED_STAGE_SHA}" ]] || {
  echo "[ERROR] scorer hash mismatch: expected=${EXPECTED_STAGE_SHA} actual=${actual_stage_sha}" >&2
  exit 5
}

for required in \
  "${OFFICIAL_ROOT}/evaluation_benchmark/scripts/eval_common.py" \
  "${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py" \
  "${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json" \
  "${OFFICIAL_ROOT}/evaluation_benchmark/bddl/1_cookies_tomato_basket.bddl"; do
  [[ -f "${required}" ]] || {
    echo "[ERROR] required official file is absent: ${required}" >&2
    exit 6
  }
done

printf 'OFFICIAL_OK commit=%s scorer_sha256=%s root=%s\n' \
  "${actual_commit}" "${actual_stage_sha}" "${OFFICIAL_ROOT}"
