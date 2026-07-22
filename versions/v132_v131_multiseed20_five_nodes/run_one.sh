#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${VERSION_DIR}/runtime/task24"
EXPECTED_OFFICIAL_COMMIT=62214036103ee8d5fef9b475dd8b344b6e2cfc03

: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE to an ignored local input file}"
: "${SEED:?set SEED}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs: ${PRIVATE_INPUTS_FILE}" >&2; exit 2; }

# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
# Historical v131 login shells inherited this exact public configuration name.
# Make it explicit so non-login Slurm workers do not depend on inherited state.
export VLA_CONFIG="${VLA_CONFIG:-pi05_libero_robomemarena_fullvlm_v2_noflip_dataset}"
for required in \
  OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH ROBOMEMARENA_REMOTE_ROOT \
  ROBOMEMARENA_FULLVLM_DATA_ROOT VLA_POLICY VLA_REPO_ID \
  VLM_CKPT_TASK24; do
  [[ -n "${!required:-}" && -e "${!required}" ]] || {
    echo "missing required private input ${required}" >&2
    exit 2
  }
done
[[ -n "${VLA_CONFIG}" ]] || { echo "missing required VLA_CONFIG" >&2; exit 2; }

if [[ -d "${ROBOMEMARENA_REMOTE_ROOT}/.git" ]]; then
  actual_commit="$(git -C "${ROBOMEMARENA_REMOTE_ROOT}" rev-parse HEAD)"
elif [[ -r "${ROBOMEMARENA_REMOTE_ROOT}/COMMIT" ]]; then
  actual_commit="$(tr -d '[:space:]' < "${ROBOMEMARENA_REMOTE_ROOT}/COMMIT")"
else
  actual_commit=unknown
fi
[[ "${actual_commit}" == "${EXPECTED_OFFICIAL_COMMIT}" ]] || {
  echo "official scorer mismatch: expected=${EXPECTED_OFFICIAL_COMMIT} actual=${actual_commit}" >&2
  exit 3
}
[[ -r "${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py" ]] || {
  echo "missing latest task2_26_reference_stage.py" >&2
  exit 3
}

if [[ "${PREFLIGHT_ONLY:-0}" == "1" ]]; then
  printf 'PREFLIGHT_OK task=24 scorer=%s seed=%s\n' "${actual_commit}" "${SEED}"
  exit 0
fi

export MODE=vlm_free
export NUM_TRIALS=1
export MAX_STEPS="${MAX_STEPS:-2000}"
export REPLAN_STEPS="${REPLAN_STEPS:-5}"
export VLM_CKPT="${VLM_CKPT_TASK24}"
export VLA_POLICY VLA_CONFIG VLA_REPO_ID
export OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH ROBOMEMARENA_REMOTE_ROOT
export ROBOMEMARENA_FULLVLM_DATA_ROOT
export STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
export RUN_ID="${RUN_ID:-task24_v132_seed${SEED}_${STAMP}}"
export OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
export REPRO_ENTRY_LAUNCHER="${BASH_SOURCE[0]}"

exec bash "${RUNTIME_DIR}/scripts/run_task24_v130_pickpopcorn_tol007_keepdirection_latest622_1ep.sh"
