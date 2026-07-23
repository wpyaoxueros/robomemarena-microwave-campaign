#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

: "${OPENPI_ROOT:?set OPENPI_ROOT}"
: "${INFER_ROOT:?set INFER_ROOT}"
: "${TARGET_LIBERO_PATH:?set TARGET_LIBERO_PATH}"
: "${ROBOMEMARENA_REMOTE_ROOT:?set ROBOMEMARENA_REMOTE_ROOT}"
: "${VLA_POLICY:?set VLA_POLICY}"
: "${VLM_CKPT:?set VLM_CKPT}"

OFFICIAL_COMMIT="d9f83ac5182e25ad7f0a301a77a0b667f2392df1"
[[ "$(git -C "${ROBOMEMARENA_REMOTE_ROOT}" rev-parse HEAD)" == "${OFFICIAL_COMMIT}" ]] || {
  echo "RoboMemArena must be detached at ${OFFICIAL_COMMIT}" >&2
  exit 2
}

BASE_EVAL="${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py"
OFFICIAL_SCRIPTS="${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/scripts"
TASK_CONFIG_PATH="${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json"
for required in "${BASE_EVAL}" "${OFFICIAL_SCRIPTS}/task2_26_reference_stage.py" "${TASK_CONFIG_PATH}" "${VLA_POLICY}/params" "${VLM_CKPT}/model.safetensors"; do
  [[ -e "${required}" ]] || { echo "missing required path: ${required}" >&2; exit 3; }
done

export VLA_REPO_ID="${VLA_REPO_ID:-${PACK_DIR}/assets/norm_repo}"
[[ -f "${VLA_REPO_ID}/norm_stats.json" ]] || { echo "missing norm_stats.json" >&2; exit 3; }
export OUTPUT_ROOT="${OUTPUT_ROOT:-${PACK_DIR}/outputs}"
export NUM_TRIALS="${NUM_TRIALS:-20}"
export SEED="${SEED:-104}"
export MAX_STEPS="${MAX_STEPS:-2200}"
export REPLAN_STEPS="${REPLAN_STEPS:-10}"
export PORT="${PORT:-9314}"
export STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
export RUN_ID="${RUN_ID:-task14_v1_latestscore_35999_seed${SEED}_${STAMP}}"
export OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
mkdir -p "${OUT_ROOT}/logs"

export TASKS_JSON='[14]'
export EVAL_PY="${PACK_DIR}/evaluators/eval_tasks2_26_sync_endpose_hold_officialscore.py"
export TASKS2_26_BASE_EVAL_PY="${BASE_EVAL}"
export ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${OFFICIAL_SCRIPTS}"
export TASK_CONFIG="${TASK_CONFIG_PATH}"
export VLA_CONFIG="pi05_libero_robomemarena_fullvlm_v2_noflip_dataset"
export VLA_SERVER_PY="${PACK_DIR}/scripts/serve_policy_custom_repo.py"
export OPENPI_PYTHON="${OPENPI_PYTHON:-${OPENPI_ROOT}/.venv/bin/python3}"
export INFER_PYTHON="${INFER_PYTHON:-${INFER_ROOT}/.venv/bin/python}"
export VLA_ACTION_TARGET_MODE=raw DISABLE_OUTPUT_NORMALIZE=1
export ENDPOSE_HOLD_TARGETS_JSON="${PACK_DIR}/config/task14_eef_targets.json"
export ENDPOSE_TARGET_PASSAGE_COUNTS_JSON="${PACK_DIR}/config/task14_passage_counts.json"
export ENDPOSE_HOLD_POS_TOL=0.06 ENDPOSE_HOLD_EEF_DEFAULT_TOL=0.06
export ENDPOSE_HOLD_EEF_P95_EXTRA_TOL=0.02 ENDPOSE_HOLD_EEF_TOL_CAP=0.08
export ENDPOSE_HOLD_MIN_ACTIVE_STEPS=20 ENDPOSE_HOLD_CONSECUTIVE=2
export POST_HOLD_RELEASE_VLA_STEPS=30 STRICT_HOLD_RELEASE_NEXT=0
export PREVENT_SUBTASK_REGRESSION=1 REGRESSION_GUARD_AFTER_HOLD_RELEASE=1
export HOLD_RELEASE_BLOCK_PAST_SUBTASKS=0 DRAWER_FORWARD_ADVANCE_GUARD=1
export DRAWER_OPEN_STAGE_THRESH=0.10 DRAWER_CLOSE_STAGE_THRESH=0.08 DRAWER_STAGE_DEBUG_INTERVAL=0
export ENDPOSE_PICK_GRIPPER_GATE=1 ENDPOSE_PICK_OBJECT_LIFT_GATE=1 ENDPOSE_PICK_OBJECT_LIFT_DELTA=0.01
export VLM_TASK_TEXT_MODE=english_reference_no_candidate VLM_COMPLETED_SUBTASKS_MODE=completed_struct
export SUBTASK_RELEASE_ANCHORS_JSON='' ENDPOSE_HOLD_POS_TOL_BY_SUBTASK_FILE=''

# VLM supplies prompts; no evaluator path may inject a next primitive.
export ORACLE_HOLD_RELEASE_NEXT=0 ORACLE_FORCE_INITIAL_PROMPT=0
export ORACLE_INITIAL_STAGE_LOCK=0 ORACLE_STAGE_ADVANCE_NEXT=0
export ORACLE_MONOTONIC_SEQUENCE_LOCK=0 ORACLE_STAGE_LOCK_UNTIL_DONE=0

{
  echo "version=v1_latestscore_35999_20ep"
  echo "official_commit=${OFFICIAL_COMMIT}"
  echo "vla_label=fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999"
  echo "vlm_label=task14_english_ref_20260702_140740_ckpt1000"
  echo "norm_sha256=$(sha256sum "${VLA_REPO_ID}/norm_stats.json" | awk '{print $1}')"
  echo "evaluator_sha256=$(sha256sum "${EVAL_PY}" | awk '{print $1}')"
  echo "launcher_sha256=$(sha256sum "${BASH_SOURCE[0]}" | awk '{print $1}')"
  echo "num_trials=${NUM_TRIALS} seed=${SEED} max_steps=${MAX_STEPS} replan_steps=${REPLAN_STEPS}"
} > "${OUT_ROOT}/run_manifest.txt"

exec bash "${PACK_DIR}/evaluators/run_tasks2_26_sync_hold_eval_customrepo.sh"
