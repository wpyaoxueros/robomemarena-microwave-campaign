#!/usr/bin/env bash
set -euo pipefail

# One-episode compatibility check. This intentionally uses the unchanged
# archived rollout body and the current d9 scorer adapter, but exposes one GPU
# to both processes so the generic runner binds VLA=0 and VLM=0.
TASK_ID=${1:?usage: run_archived_single_gpu_preflight.sh TASK_ID RUNTIME_ENV}
RUNTIME_ENV=${2:?usage: run_archived_single_gpu_preflight.sh TASK_ID RUNTIME_ENV}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${TASK_ID}" in
  3|12|13|18|25|26) ;;
  *) echo "unsupported archived single-GPU preflight task: ${TASK_ID}" >&2; exit 2 ;;
esac
[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside Slurm" >&2; exit 2; }
[[ -r "${RUNTIME_ENV}" ]] || { echo "missing runtime env: ${RUNTIME_ENV}" >&2; exit 2; }
[[ -n "${OUTPUT_ROOT_OVERRIDE:-}" ]] || { echo "set OUTPUT_ROOT_OVERRIDE" >&2; exit 2; }

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"
OUTPUT_ROOT="${OUTPUT_ROOT_OVERRIDE}"
ARCHIVED_TASKS_EVAL="${CAMPAIGN_DIR}/adapters/eval_tasks2_26_sync_endpose_hold_d9_compat.py"

"${CAMPAIGN_DIR}/scripts/assert_official_d9f83ac.sh" "${OFFICIAL_ROOT}"
EXPECTED_NORM_SHA=4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a
actual_norm_sha="$(sha256sum "${VLA_NORM_FILE}" | awk '{print $1}')"
[[ "${actual_norm_sha}" == "${EXPECTED_NORM_SHA}" ]] || {
  echo "VLA norm mismatch: ${actual_norm_sha}" >&2
  exit 3
}

if [[ -n "${CUDA_VISIBLE_DEVICES:-}" ]]; then
  IFS=',' read -r -a visible_gpu_ids <<< "${CUDA_VISIBLE_DEVICES}"
  visible_gpu_count=${#visible_gpu_ids[@]}
else
  visible_gpu_count="$(nvidia-smi -L | wc -l | tr -d ' ')"
fi
[[ "${visible_gpu_count}" == "1" ]] || {
  echo "single-GPU preflight requires exactly one visible GPU, got ${visible_gpu_count}" >&2
  exit 4
}

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

SEED=${SEED:-104}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task${TASK_ID}_d9_single_gpu_preflight_seed${SEED}_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/single_gpu_preflight/task${TASK_ID}/${RUN_ID}"
PORT=${PORT:-$((9700 + TASK_ID))}
mkdir -p "${OUT_ROOT}"

cat > "${OUT_ROOT}/preflight_manifest.env" <<EOF
task_id=${TASK_ID}
kind=single_gpu_colocation_preflight
remote_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
norm_sha256=${actual_norm_sha}
unix_user=$(id -un)
slurm_job_id=${SLURM_JOB_ID}
visible_gpu_count=${visible_gpu_count}
gpu_binding=VLA:0,VLM:0
num_trials=1
seed=${SEED}
EOF

env \
  OPENPI_ROOT="${OPENPI_ROOT}" \
  INFER_ROOT="${INFER_ROOT}" \
  TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
  RUN_ID="${RUN_ID}" \
  OUT_ROOT="${OUT_ROOT}" \
  PORT="${PORT}" \
  VLM_CKPT="${VLM_CKPT}" \
  VLA_CONFIG=pi05_libero_robomemarena_fullvlm_v2_noflip_dataset \
  VLA_POLICY="${VLA_POLICY}" \
  VLA_REPO_ID="$(dirname "${VLA_NORM_FILE}")" \
  VLA_CUDA_VISIBLE_DEVICES=0 \
  VLM_CUDA_VISIBLE_DEVICES=0 \
  TASKS_JSON="[${TASK_ID}]" \
  NUM_TRIALS=1 \
  SEED="${SEED}" \
  MAX_STEPS="${MAX_STEPS}" \
  REPLAN_STEPS="${REPLAN_STEPS}" \
  EVAL_PY="${ARCHIVED_TASKS_EVAL}" \
  TASKS2_26_BASE_EVAL_PY="${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py" \
  TASK_CONFIG="${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json" \
  ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${OFFICIAL_ROOT}/evaluation_benchmark/scripts" \
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
