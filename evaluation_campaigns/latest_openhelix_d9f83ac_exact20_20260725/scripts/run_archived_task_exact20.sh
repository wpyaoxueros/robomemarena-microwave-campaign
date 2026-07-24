#!/usr/bin/env bash
set -euo pipefail

# This runner preserves the historical rollout flags for the archived success
# pack, while replacing its old official source root with OpenHelix@d9f83ac.
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TASK_ID=${1:?usage: run_archived_task_exact20.sh TASK_ID}

if [[ -n "${RUNTIME_ENV:-}" ]]; then
  # shellcheck disable=SC1090
  source "${RUNTIME_ENV}"
fi

# A private archived environment may carry the output root of the account that
# produced the original result.  A borrowed submit account may override only
# this artifact location; checkpoint, norm, rollout and scoring inputs remain
# entirely sourced from the frozen environment.
if [[ -n "${OUTPUT_ROOT_OVERRIDE:-}" ]]; then
  OUTPUT_ROOT="${OUTPUT_ROOT_OVERRIDE}"
fi

for name in \
  OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH OFFICIAL_ROOT OUTPUT_ROOT \
  VLA_POLICY VLA_NORM_FILE VLA_LABEL VLM_CKPT VLM_LABEL \
  ARCHIVED_SYNC_RUNNER ARCHIVED_TASKS_EVAL TASK1_RUNNER TASK1_EVAL \
  ENDPOSE_HOLD_TARGETS_JSON ENDPOSE_TARGET_PASSAGE_COUNTS_GENERAL \
  ENDPOSE_TARGET_PASSAGE_COUNTS_DRAWER; do
  [[ -n "${!name:-}" ]] || { echo "[ERROR] set ${name}" >&2; exit 2; }
done

case "${TASK_ID}" in
  1|3|12|13|18|25|26) ;;
  *) echo "[ERROR] archived exact20 runner does not own task ${TASK_ID}" >&2; exit 2 ;;
esac

"${CAMPAIGN_DIR}/scripts/assert_official_d9f83ac.sh" "${OFFICIAL_ROOT}"

EXPECTED_NORM_SHA=4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a
EXPECTED_STAGE_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538
actual_norm_sha="$(sha256sum "${VLA_NORM_FILE}" | awk '{print $1}')"
[[ "${actual_norm_sha}" == "${EXPECTED_NORM_SHA}" ]] || {
  echo "[ERROR] VLA norm mismatch: expected=${EXPECTED_NORM_SHA} actual=${actual_norm_sha}" >&2
  exit 3
}

NUM_TRIALS=${NUM_TRIALS:-20}
SEED=${SEED:-104}
[[ "${NUM_TRIALS}" == "20" ]] || {
  echo "[ERROR] this formal launcher requires exactly 20 episodes, got ${NUM_TRIALS}" >&2
  exit 4
}

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task${TASK_ID}_openhelix_d9f83ac_exact20_seed${SEED}_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/task${TASK_ID}/${RUN_ID}"
mkdir -p "${OUT_ROOT}/code_snapshot/official_scripts" "${OUT_ROOT}/code_snapshot/official_bddl"

cp -p "${CAMPAIGN_DIR}/scripts/run_archived_task_exact20.sh" "${OUT_ROOT}/code_snapshot/"
cp -p "${CAMPAIGN_DIR}/scripts/assert_official_d9f83ac.sh" "${OUT_ROOT}/code_snapshot/"
cp -p "${ARCHIVED_SYNC_RUNNER}" "${OUT_ROOT}/code_snapshot/"
cp -p "${ARCHIVED_TASKS_EVAL}" "${OUT_ROOT}/code_snapshot/"
cp -p "${TASK1_RUNNER}" "${OUT_ROOT}/code_snapshot/"
cp -p "${TASK1_EVAL}" "${OUT_ROOT}/code_snapshot/"
cp -p "${OFFICIAL_ROOT}/evaluation_benchmark/scripts/eval_common.py" "${OUT_ROOT}/code_snapshot/official_scripts/"
cp -p "${OFFICIAL_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py" "${OUT_ROOT}/code_snapshot/official_scripts/"
cp -p "${OFFICIAL_ROOT}/evaluation_benchmark/bddl/${TASK_ID}_"*.bddl "${OUT_ROOT}/code_snapshot/official_bddl/"

cat > "${OUT_ROOT}/run_manifest.env" <<EOF
task_id=${TASK_ID}
remote_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
remote_stage_sha256=${EXPECTED_STAGE_SHA}
vla_label=${VLA_LABEL}
vlm_label=${VLM_LABEL}
norm_sha256=${actual_norm_sha}
num_trials=${NUM_TRIALS}
seed=${SEED}
EOF

BASE_EVAL="${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py"
TASK_CONFIG="${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json"
OFFICIAL_SCRIPTS="${OFFICIAL_ROOT}/evaluation_benchmark/scripts"

if [[ "${TASK_ID}" == "1" ]]; then
  TASK1_RUN_ROOT="${OUT_ROOT}/task1_sync/${RUN_ID}"
  env \
    RUN_ID="${RUN_ID}" \
    LOG_BASE="${OUT_ROOT}" \
    EVAL_PY="${TASK1_EVAL}" \
    TASK1_BASE_EVAL_PY="${OFFICIAL_ROOT}/evaluation_benchmark/openpi_minimal_runtime/eval_task1_qwen3_async_openpi_inference_vla_cam.py" \
    ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${OFFICIAL_SCRIPTS}" \
    TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
    BASE_MODEL_DIR="${VLM_CKPT}" \
    VLA_CONFIG=pi05_libero_robomemarena_fullvlm_v2_noflip_dataset \
    VLA_POLICY="${VLA_POLICY}" \
    NUM_TRIALS_PER_TASK=20 \
    MAX_STEPS=2000 \
    REPLAN_STEPS=5 \
    SEED="${SEED}" \
    POST_HOLD_RELEASE_VLA_STEPS=30 \
    VLM_PROMPT_PROFILE=task1_no_label_no_order \
    PREVENT_SUBTASK_REGRESSION=1 \
    REGRESSION_GUARD_AFTER_HOLD_RELEASE=1 \
    TASK1_ACCEPT_RAW_VLM_OUTPUT=1 \
    TASK1_DISABLE_OUTPUT_NORMALIZE=1 \
    bash "${TASK1_RUNNER}"
  cp -p "${TASK1_RUN_ROOT}/official_task_summary.tsv" "${OUT_ROOT}/" 2>/dev/null || true
  exit 0
fi

MAX_STEPS=2000
REPLAN_STEPS=5
PASSAGE_COUNTS="${ENDPOSE_TARGET_PASSAGE_COUNTS_GENERAL}"
DRAWER_GUARD=1
PICK_GRIPPER_GATE=1
PICK_LIFT_GATE=1
TEXT_MODE=english_reference_no_candidate
COMPLETED_MODE=off

case "${TASK_ID}" in
  3)
    PASSAGE_COUNTS=__NONE__
    DRAWER_GUARD=0
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=0
    TEXT_MODE=no_label_no_order
    ;;
  12|13)
    MAX_STEPS=2200
    REPLAN_STEPS=10
    PASSAGE_COUNTS="${ENDPOSE_TARGET_PASSAGE_COUNTS_DRAWER}"
    COMPLETED_MODE=completed_struct
    ;;
  18)
    MAX_STEPS=2200
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=1
    ;;
esac

PORT=${PORT:-$((9300 + TASK_ID))}
SYNC_OUT_ROOT="${OUT_ROOT}/logs_task_sync_hold/${RUN_ID}"
env \
  OPENPI_ROOT="${OPENPI_ROOT}" \
  INFER_ROOT="${INFER_ROOT}" \
  TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
  RUN_ID="${RUN_ID}" \
  OUT_ROOT="${SYNC_OUT_ROOT}" \
  PORT="${PORT}" \
  VLM_CKPT="${VLM_CKPT}" \
  VLA_CONFIG=pi05_libero_robomemarena_fullvlm_v2_noflip_dataset \
  VLA_POLICY="${VLA_POLICY}" \
  VLA_REPO_ID="$(dirname "${VLA_NORM_FILE}")" \
  TASKS_JSON="[${TASK_ID}]" \
  NUM_TRIALS=20 \
  SEED="${SEED}" \
  MAX_STEPS="${MAX_STEPS}" \
  REPLAN_STEPS="${REPLAN_STEPS}" \
  EVAL_PY="${ARCHIVED_TASKS_EVAL}" \
  TASKS2_26_BASE_EVAL_PY="${BASE_EVAL}" \
  TASK_CONFIG="${TASK_CONFIG}" \
  ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${OFFICIAL_SCRIPTS}" \
  ROBOMEMARENA_OFFICIAL_BDDL_DIR="${OFFICIAL_ROOT}/evaluation_benchmark/bddl" \
  ROBOMEMARENA_ROOT_BDDL_DIR="${OFFICIAL_ROOT}/bddl" \
  ENDPOSE_HOLD_TARGETS_JSON="${ENDPOSE_HOLD_TARGETS_JSON}" \
  ENDPOSE_TARGET_PASSAGE_COUNTS_JSON="${PASSAGE_COUNTS}" \
  ENDPOSE_HOLD_POS_TOL=0.06 \
  ENDPOSE_HOLD_EEF_DEFAULT_TOL=0.06 \
  ENDPOSE_HOLD_EEF_P95_EXTRA_TOL=0.02 \
  ENDPOSE_HOLD_EEF_TOL_CAP=0.08 \
  POST_HOLD_RELEASE_VLA_STEPS=30 \
  STRICT_HOLD_RELEASE_NEXT=0 \
  PREVENT_SUBTASK_REGRESSION=1 \
  REGRESSION_GUARD_AFTER_HOLD_RELEASE=1 \
  HOLD_RELEASE_BLOCK_PAST_SUBTASKS=0 \
  DRAWER_FORWARD_ADVANCE_GUARD="${DRAWER_GUARD}" \
  DRAWER_OPEN_STAGE_THRESH=0.10 \
  DRAWER_CLOSE_STAGE_THRESH=0.08 \
  ENDPOSE_PICK_GRIPPER_GATE="${PICK_GRIPPER_GATE}" \
  ENDPOSE_PICK_OBJECT_LIFT_GATE="${PICK_LIFT_GATE}" \
  ENDPOSE_PICK_OBJECT_LIFT_DELTA=0.01 \
  DISABLE_OUTPUT_NORMALIZE=1 \
  VLM_TASK_TEXT_MODE="${TEXT_MODE}" \
  VLM_COMPLETED_SUBTASKS_MODE="${COMPLETED_MODE}" \
  bash "${ARCHIVED_SYNC_RUNNER}"
