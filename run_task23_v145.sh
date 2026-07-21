#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUTS_FILE="${INPUTS_FILE:-${ROOT}/inputs.env}"
if [[ ! -f "${INPUTS_FILE}" ]]; then
  echo "missing ${INPUTS_FILE}; copy inputs.env.example and fill all paths" >&2
  exit 2
fi
# shellcheck disable=SC1090
source "${INPUTS_FILE}"

for required in OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH ROBOMEMARENA_REMOTE_ROOT VLA_POLICY VLA_REPO_ID VLM_CKPT; do
  [[ -n "${!required:-}" ]] || { echo "missing ${required} in ${INPUTS_FILE}" >&2; exit 2; }
done

export PACK_DIR="${ROOT}"
export WORKSPACE_ROOT="${WORKSPACE_ROOT:-${ROOT}}"
export MODE=vlm_free
export RUN_ID="${RUN_ID:-task23_v145_remove_cream_place_anchor}"
export OUT_ROOT="${OUT_ROOT:-${OUT_BASE:?OUT_BASE is required when OUT_ROOT is unset}/${RUN_ID}}"
export NUM_TRIALS="${NUM_TRIALS:-1}"
export SEED="${SEED:-104}"
export MAX_STEPS="${MAX_STEPS:-2000}"
export REPLAN_STEPS="${REPLAN_STEPS:-5}"
export PORT="${PORT:-9723}"

# VLM supplies every prompt. These controls only hold/release actions and
# prevent an already released primitive from becoming the active prompt again.
export VLM_COMPLETED_SUBTASKS_MODE=completed_struct
export COMPLETED_UPDATE_FROM_OFFICIAL_STAGE=1
export VLM_HOLD_STATE_HINT=1
export VLM_HOLD_STATE_HINT_PHASE=active
export PREVENT_COMPLETED_STAGE_REGRESSION=1
export PREVENT_HELD_SUBTASK_REGRESSION=1
export REQUIRE_HOLD_RELEASE_FOR_PICK_FORWARD=1
export REQUIRE_HOLD_RELEASE_FOR_PICK_FORWARD_SUBTASKS='pick cream,pick popcorn'
export REQUIRE_HOLD_RELEASE_FOR_PLACE_FORWARD=1
export BLOCK_FORWARD_BEFORE_FIRST_STAGE_DONE=1
export STOP_ON_STAGE_SUCCESS=1

export ORACLE_HOLD_RELEASE_NEXT=0
export ORACLE_FORCE_INITIAL_PROMPT=0
export ORACLE_INITIAL_STAGE_LOCK=0
export ORACLE_STAGE_ADVANCE_NEXT=0
export ORACLE_MONOTONIC_SEQUENCE_LOCK=0
export ORACLE_STAGE_LOCK_UNTIL_DONE=0
export SUBTASK_RELEASE_ANCHORS_JSON="${ROOT}/config/release_anchors_task23_v145_remove_cream_place_anchor.json"
export ENDPOSE_HOLD_TARGETS_JSON="${ROOT}/config/tasks2_26_endpose_targets_seed100_199.json"
export ENDPOSE_TARGET_PASSAGE_COUNTS_JSON="${ROOT}/config/tasks2_26_target_passage_counts_seed100_199_alltasks_tol045_20260624_074452.json"
export ENDPOSE_HOLD_POS_TOL_BY_SUBTASK_FILE="${ROOT}/config/task23_eef_open105_pick060_place060_tol_20260718.json"
export ENDPOSE_HOLD_RELEASE_MIN_STEPS_BY_SUBTASK_FILE="${ROOT}/config/task23_24_eef_runtime_pickplace_hold30_20260718.json"
export REPRO_ENTRY_LAUNCHER="${BASH_SOURCE[0]}"

exec bash "${ROOT}/scripts/run_microwave_eefonly_no_object_gate.sh" 23
