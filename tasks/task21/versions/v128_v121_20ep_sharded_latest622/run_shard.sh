#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"

: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE to an untracked local env file}"
: "${SEED:?set SEED}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -f "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }
[[ "${SEED}" =~ ^[0-9]+$ ]] || { echo "SEED must be numeric" >&2; exit 2; }

# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
for required in OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH ROBOMEMARENA_REMOTE_ROOT TASK21_DATA_ROOT VLA_POLICY VLM_CKPT; do
  [[ -n "${!required:-}" ]] || { echo "missing ${required} in private inputs" >&2; exit 2; }
done

export STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
export RUN_ID="${RUN_ID:-task21_v128_seed${SEED}_${STAMP}}"
export OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
export REPRO_ENTRY_LAUNCHER="${BASH_SOURCE[0]}"
export TASK21_RELEASE_ANCHOR_TEMPLATE="${VERSION_DIR}/release_anchors.empty.object.json"
export NUM_TRIALS="${NUM_TRIALS:-4}"
[[ "${NUM_TRIALS}" == "4" ]] || { echo "v128 requires NUM_TRIALS=4" >&2; exit 2; }

# Frozen V121 wrapper contract. The downstream V108/V110 scripts preserve these
# values because they use defaults only when the values are unset.
export VLA_REPO_ID="${VLA_REPO_ID:-${PACK_DIR}/assets/norm_repo}"
export MAX_STEPS=2000
export REPLAN_STEPS=5
export ORACLE_HOLD_RELEASE_NEXT=0
export ORACLE_FORCE_INITIAL_PROMPT=0
export ORACLE_INITIAL_STAGE_LOCK=0
export ORACLE_STAGE_ADVANCE_NEXT=0
export ORACLE_MONOTONIC_SEQUENCE_LOCK=0
export ORACLE_STAGE_LOCK_UNTIL_DONE=0
export RUN_VERSION=v121_nopick2place_upward
export ENDPOSE_HOLD_TARGETS_JSON="${PACK_DIR}/config/task21_v121_eef_targets.json"
export ENDPOSE_HOLD_POS_TOL_BY_SUBTASK_FILE="${PACK_DIR}/config/task21_v121_eef_tolerances.json"
export ENDPOSE_TARGET_PASSAGE_COUNTS_JSON="${PACK_DIR}/config/task21_v121_passages.json"
export ENDPOSE_HOLD_DIRECTION_SIGNATURES_JSON="${PACK_DIR}/config/task21_v121_pick_directions.json"
export ENDPOSE_HOLD_DIRECTION_COS_MIN=0.50
export ENDPOSE_HOLD_DIRECTION_WINDOW=3
export ENDPOSE_HOLD_DIRECTION_MIN_DISPLACEMENT=0.001
export ENDPOSE_HOLD_DIRECTION_TREND_EPS=0.03
export ENDPOSE_HOLD_RELEASE_MIN_STEPS_BY_SUBTASK_FILE="${PACK_DIR}/config/task21_v121_min_hold_steps.json"
export POST_PICK_HOLD_RELEASE_SAME_PROMPT_STEPS=50

mkdir -p "${OUT_ROOT}/runtime_config"
python3 "${PACK_DIR}/scripts/materialize_task21_paths.py" \
  --template "${TASK21_RELEASE_ANCHOR_TEMPLATE}" \
  --output "${OUT_ROOT}/runtime_config/task21_v121_release_anchors.json" \
  --data-root "${TASK21_DATA_ROOT}"
export SUBTASK_RELEASE_ANCHORS_JSON="${OUT_ROOT}/runtime_config/task21_v121_release_anchors.json"

exec bash "${PACK_DIR}/scripts/run_task21_v110_historicalvlm_eef_pickfinish50_latest622_1ep.sh"
