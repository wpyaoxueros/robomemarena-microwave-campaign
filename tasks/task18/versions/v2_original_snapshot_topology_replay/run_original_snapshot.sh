#!/usr/bin/env bash
set -euo pipefail

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "[ERROR] ${name} is required" >&2
    exit 2
  fi
}

for name in SNAPSHOT_DIR TASKS2_26_BASE_EVAL_PY VLM_CKPT VLA_POLICY OUT_ROOT; do
  require_env "${name}"
done

FILES_DIR="${SNAPSHOT_DIR}/files"
EVAL_PY="${FILES_DIR}/eval_py__eval_tasks2_26_sync_endpose_hold.py"
HISTORICAL_LAUNCHER="${FILES_DIR}/launcher__run_tasks2_26_sync_hold_eval.sh"
TARGETS_JSON="${FILES_DIR}/endpose_hold_targets__tasks2_26_endpose_targets_seed100_199.json"
PASSAGE_JSON="${FILES_DIR}/passage_counts__tasks2_26_target_passage_counts_seed100_199_alltasks_tol045_20260624_074452.json"

for path in "${EVAL_PY}" "${HISTORICAL_LAUNCHER}" "${TARGETS_JSON}" "${PASSAGE_JSON}"; do
  if [[ ! -r "${path}" ]]; then
    echo "[ERROR] historical snapshot artifact is unavailable: ${path}" >&2
    exit 2
  fi
done

check_sha() {
  local expected="$1"
  local path="$2"
  local actual
  actual="$(sha256sum "${path}" | awk '{print $1}')"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "[ERROR] historical source hash mismatch: ${path}" >&2
    echo "[ERROR] expected=${expected} actual=${actual}" >&2
    exit 3
  fi
}

check_sha 7367e68f05712d4620429ecdbebbcbe6289da6613863db6dfcee926e8216b4c1 "${EVAL_PY}"
check_sha 11aba57fac364c8e9fc9f430c44edf7677defcdd00982667b75e07f98cc9cebd "${HISTORICAL_LAUNCHER}"
check_sha 8921ddbbda123ad419ac563397bb47ab95e3e696ee483c15d357f294beb5003d "${TARGETS_JSON}"
check_sha 4fb11fb0e440b42afd95674219ae007d75e29ae140f846d7221763987fbf54c6 "${PASSAGE_JSON}"

mkdir -p "${OUT_ROOT}"

# Do not let a modern campaign wrapper substitute the historical rollout code.
unset ARCHIVED_TASKS_EVAL_OVERRIDE
unset ARCHIVED_TASKS_EVAL
unset OFFICIAL_STAGE_MODULE

export TASKS_JSON='[18]'
export NUM_TRIALS=5
export SEED=104
export MAX_STEPS=2200
export REPLAN_STEPS=5
export RUN_ID="${RUN_ID:-task18_original_snapshot_seed104_$(date +%Y%m%d_%H%M%S)}"

export EVAL_PY
export TASKS2_26_BASE_EVAL_PY
export ENDPOSE_HOLD_TARGETS_JSON="${TARGETS_JSON}"
export ENDPOSE_TARGET_PASSAGE_COUNTS_JSON="${PASSAGE_JSON}"
export VLA_CONFIG="${VLA_CONFIG:-pi05_libero_robomemarena_fullvlm_v2_noflip_dataset}"
export VLA_ACTION_TARGET_MODE=raw
export VLM_TASK_TEXT_MODE=english_reference_no_candidate
export VLM_COMPLETED_SUBTASKS_MODE=off
export ENDPOSE_HOLD_POS_TOL=0.06
export ENDPOSE_HOLD_EEF_DEFAULT_TOL=0.06
export ENDPOSE_HOLD_EEF_P95_EXTRA_TOL=0.02
export ENDPOSE_HOLD_EEF_TOL_CAP=0.08
export ENDPOSE_HOLD_MIN_ACTIVE_STEPS=20
export ENDPOSE_HOLD_CONSECUTIVE=2
export ENDPOSE_HOLD_DISABLE_FINAL=1
export POST_HOLD_RELEASE_VLA_STEPS=30
export STRICT_HOLD_RELEASE_NEXT=0
export PREVENT_SUBTASK_REGRESSION=1
export REGRESSION_GUARD_AFTER_HOLD_RELEASE=1
export HOLD_RELEASE_BLOCK_PAST_SUBTASKS=0
export DRAWER_FORWARD_ADVANCE_GUARD=1
export DRAWER_OPEN_STAGE_THRESH=0.10
export DRAWER_CLOSE_STAGE_THRESH=0.08
export DRAWER_STAGE_DEBUG_INTERVAL=0
export ENDPOSE_PICK_GRIPPER_GATE=0
export ENDPOSE_PICK_OBJECT_LIFT_GATE=0
export ENDPOSE_PICK_OBJECT_LIFT_DELTA=0.01
export DISABLE_OUTPUT_NORMALIZE=1
export VLA_CUDA_VISIBLE_DEVICES="${VLA_CUDA_VISIBLE_DEVICES:-0}"
export VLM_CUDA_VISIBLE_DEVICES="${VLM_CUDA_VISIBLE_DEVICES:-1}"
export REQUIRE_REPRO_SNAPSHOT=1
export REPRO_SNAPSHOT_LAUNCHER="${HISTORICAL_LAUNCHER}"
export REPRO_SNAPSHOT_EXTRA_FILES="${SNAPSHOT_DIR}/MANIFEST.txt"

printf '%s\n' \
  "historical_evaluator_sha=7367e68f05712d4620429ecdbebbcbe6289da6613863db6dfcee926e8216b4c1" \
  "historical_launcher_sha=11aba57fac364c8e9fc9f430c44edf7677defcdd00982667b75e07f98cc9cebd" \
  "modern_adapter=disabled" \
  "tasks=${TASKS_JSON}" \
  "trials=${NUM_TRIALS}" \
  "seed=${SEED}" \
  "max_steps=${MAX_STEPS}" \
  "replan_steps=${REPLAN_STEPS}" \
  > "${OUT_ROOT}/original_runtime_identity.txt"

exec bash "${HISTORICAL_LAUNCHER}"
