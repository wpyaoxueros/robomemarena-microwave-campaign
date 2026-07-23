#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
PRIVATE_INPUTS_FILE="${1:-${VERSION_DIR}/inputs.env}"
REMOTE_ROOT_OVERRIDE="${ROBOMEMARENA_REMOTE_ROOT_OVERRIDE:?set ROBOMEMARENA_REMOTE_ROOT_OVERRIDE to the repaired checkout}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || {
  echo "missing private inputs: ${PRIVATE_INPUTS_FILE}" >&2
  exit 2
}
PRIVATE_INPUTS_FILE="$(readlink -f "${PRIVATE_INPUTS_FILE}")"
# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
export ROBOMEMARENA_REMOTE_ROOT="${REMOTE_ROOT_OVERRIDE}"

: "${ROBOMEMARENA_REMOTE_ROOT:?set ROBOMEMARENA_REMOTE_ROOT in private inputs}"
: "${OPENPI_ROOT:?set OPENPI_ROOT in private inputs}"
: "${INFER_ROOT:?set INFER_ROOT in private inputs}"
: "${TARGET_LIBERO_PATH:?set TARGET_LIBERO_PATH in private inputs}"
: "${VLA_POLICY:?set VLA_POLICY in private inputs}"
: "${VLA_CONFIG:?set VLA_CONFIG in private inputs}"
: "${VLM_CKPT:?set VLM_CKPT in private inputs}"
export ROBOMEMARENA_VERIFY_PYTHON="${INFER_ROOT}/.venv/bin/python"

# Use the original checkpoint's own asset ID.  This prevents the policy server
# from silently falling back after receiving an equivalent external norm path.
export VLA_REPO_ID="${VLA_POLICY}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2"

export EXPECTED_OFFICIAL_COMMIT=8b7710924f862ab1c8dea69adada62e8c462de40
export ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/scripts"
export ROBOMEMARENA_OFFICIAL_BDDL_DIR="${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/bddl"
export ROBOMEMARENA_ROOT_BDDL_DIR="${ROBOMEMARENA_REMOTE_ROOT}/bddl"
export TASKS2_26_BASE_EVAL_PY="${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py"
export TASK_CONFIG="${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json"
export EVAL_PY="${PACK_DIR}/evaluators/eval_tasks2_26_sync_endpose_hold_officialscore.py"

export MODE=vlm_free
export NUM_TRIALS=1
export SEED=104
export MAX_STEPS=2000
export REPLAN_STEPS=10
export PORT="${PORT:-19427}"
export RUN_ID="${RUN_ID:-task22_v17_35999_pickonly_eef_gate_seed104_$(date +%Y%m%d_%H%M%S)}"
export OUTPUT_ROOT="${OUTPUT_ROOT:-${VERSION_DIR}/outputs}"
export OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"

export ORACLE_HOLD_RELEASE_NEXT=0
export ORACLE_FORCE_INITIAL_PROMPT=0
export ORACLE_INITIAL_STAGE_LOCK=0
export ORACLE_STAGE_ADVANCE_NEXT=0
export ORACLE_MONOTONIC_SEQUENCE_LOCK=0
export ORACLE_STAGE_LOCK_UNTIL_DONE=0
export VLM_COMPLETED_SUBTASKS_MODE=off
export COMPLETED_UPDATE_FROM_OFFICIAL_STAGE=0
export VLM_HOLD_STATE_HINT=0
export BLOCK_FORWARD_BEFORE_FIRST_STAGE_DONE=0
export REQUIRE_INITIAL_VLM_SUBTASK=1
export REQUIRE_HOLD_RELEASE_FOR_PICK_FORWARD=0
export REQUIRE_HOLD_RELEASE_FOR_PLACE_FORWARD=0
export REQUIRE_HOLD_RELEASE_FOR_FORWARD=1
export REQUIRE_HOLD_RELEASE_FOR_FORWARD_SUBTASKS="pick tomato"
export STRICT_HOLD_RELEASE_NEXT=0
export MICROWAVE_FORWARD_REQUIRE_PRIOR_HOLD=0
export PREVENT_COMPLETED_STAGE_REGRESSION=0
export PREVENT_SUBTASK_REGRESSION=1
export PREVENT_HELD_SUBTASK_REGRESSION=1
export HOLD_RELEASE_BLOCK_PAST_SUBTASKS=1
export STOP_ON_STAGE_SUCCESS=1
export REQUIRE_OPEN_MICROWAVE_ENDPOSE_HOLD_BEFORE_RELEASE=0
export MICROWAVE_REQUIRE_OPEN_EEF_HOLD_FOR_SUCCESS=0

export ENDPOSE_PLACE_OBJECT_GATE_JSON=
export ENDPOSE_PICK_OBJECT_LIFT_GATE=0
export ENDPOSE_PICK_OBJECT_LIFT_GATE_BY_SUBTASK_JSON='{}'
export ENDPOSE_PICK_HEIGHT_REQUIRE_EEF_NEAR=0
export ENDPOSE_PICK_GRIPPER_GATE=0
export ENDPOSE_PICK_DEFERRED_GRIPPER_RELEASE=0
export ENDPOSE_HOLD_POS_TOL=0.08
export ENDPOSE_HOLD_EEF_DEFAULT_TOL=0.08
export ENDPOSE_HOLD_EEF_TOL_CAP=0.08
export ENDPOSE_HOLD_MIN_ACTIVE_STEPS=20
export ENDPOSE_HOLD_CONSECUTIVE_BY_SUBTASK_JSON='{"pick tomato": 2}'
export POST_HOLD_RELEASE_VLA_STEPS=50
export SUBTASK_RELEASE_ANCHORS_JSON="${PACK_DIR}/config/release_anchors_t22_v2_robotonly.json"
export ENDPOSE_HOLD_TARGETS_JSON="${PACK_DIR}/config/task22_pick_tomato_only_endpose_targets.json"
export REPRO_ENTRY_LAUNCHER="${BASH_SOURCE[0]}"

"${VERSION_DIR}/verify_vla35999_inputs.sh" "${PRIVATE_INPUTS_FILE}"
"${VERSION_DIR}/verify_pick_only_hold_targets.sh" "${ENDPOSE_HOLD_TARGETS_JSON}"
"${VERSION_DIR}/verify_remote_patch.sh"
exec bash "${PACK_DIR}/scripts/launch_one_sync_hold_orig35999.sh" 22
