#!/usr/bin/env bash
set -euo pipefail

# Keep Task14's frozen rollout configuration.  The only replacement is the
# already-audited adapter that translates the current d9 evaluator callback.
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACK_DIR="${CAMPAIGN_DIR}/tasks/task14/versions/v1_latestscore_35999_20ep"
D9_CAMPAIGN="${CAMPAIGN_DIR}/evaluation_campaigns/latest_openhelix_d9f83ac_exact20_20260725"

OPENPI_ROOT=${OPENPI_ROOT:-/data/user/hlei573/openpi}
INFER_ROOT=${INFER_ROOT:-/data/user/hlei573/openpi_inference}
OFFICIAL_ROOT=${OFFICIAL_ROOT:-/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725}
TARGET_LIBERO_PATH=${TARGET_LIBERO_PATH:-/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork}
VLA_POLICY=${VLA_POLICY:-/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999}
VLA_REPO_ID=${VLA_REPO_ID:-${VLA_POLICY}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2}
VLM_CKPT=${VLM_CKPT:-/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_20260702_140540_task14_choco_pickpersist/eval_artifacts/vlm_eval_ready/task14_task14_english_ref_20260702_140740_ckpt1000_20260702_151642/task14_english_ref_20260702_140740_ckpt1000}

OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to an account-owned output root}
NUM_TRIALS=${NUM_TRIALS:-1}
SEED=${SEED:-104}
MAX_STEPS=${MAX_STEPS:-2200}
REPLAN_STEPS=${REPLAN_STEPS:-10}
PORT=${PORT:-9314}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task14_v1_d9compat_seed${SEED}_${STAMP}}
OUT_ROOT=${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}

EXPECTED_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
EXPECTED_STAGE_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538
EXPECTED_NORM_SHA=4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a
EVAL_PY="${D9_CAMPAIGN}/adapters/eval_tasks2_26_sync_endpose_hold_d9_compat.py"
BASE_EVAL="${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py"
OFFICIAL_SCRIPTS="${OFFICIAL_ROOT}/evaluation_benchmark/scripts"
TASK_CONFIG="${OFFICIAL_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json"

[[ "$(git -C "${OFFICIAL_ROOT}" rev-parse HEAD)" == "${EXPECTED_COMMIT}" ]]
[[ "$(sha256sum "${OFFICIAL_SCRIPTS}/task2_26_reference_stage.py" | awk '{print $1}')" == "${EXPECTED_STAGE_SHA}" ]]
[[ "$(sha256sum "${VLA_REPO_ID}/norm_stats.json" | awk '{print $1}')" == "${EXPECTED_NORM_SHA}" ]]
[[ -r "${EVAL_PY}" && -r "${BASE_EVAL}" && -r "${VLM_CKPT}/model.safetensors" && -r "${VLA_POLICY}/params" ]]

mkdir -p "${OUT_ROOT}/logs"
cat > "${OUT_ROOT}/run_manifest.env" <<EOF
task_id=14
remote_commit=${EXPECTED_COMMIT}
remote_stage_sha256=${EXPECTED_STAGE_SHA}
vla_policy=${VLA_POLICY}
vla_norm=${VLA_REPO_ID}/norm_stats.json
vla_norm_sha256=${EXPECTED_NORM_SHA}
vlm_ckpt=${VLM_CKPT}
compat_adapter=${EVAL_PY}
num_trials=${NUM_TRIALS}
seed=${SEED}
max_steps=${MAX_STEPS}
replan_steps=${REPLAN_STEPS}
gpu_binding=VLA:${VLA_CUDA_VISIBLE_DEVICES:-auto};VLM:${VLM_CUDA_VISIBLE_DEVICES:-auto}
oracle_hold_release_next=0
oracle_force_initial_prompt=0
oracle_stage_advance_next=0
EOF

exec env \
  OPENPI_ROOT="${OPENPI_ROOT}" \
  INFER_ROOT="${INFER_ROOT}" \
  TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
  RUN_ID="${RUN_ID}" \
  OUT_ROOT="${OUT_ROOT}" \
  PORT="${PORT}" \
  VLM_CKPT="${VLM_CKPT}" \
  VLA_CONFIG=pi05_libero_robomemarena_fullvlm_v2_noflip_dataset \
  VLA_POLICY="${VLA_POLICY}" \
  VLA_REPO_ID="${VLA_REPO_ID}" \
  TASKS_JSON='[14]' \
  NUM_TRIALS="${NUM_TRIALS}" \
  SEED="${SEED}" \
  MAX_STEPS="${MAX_STEPS}" \
  REPLAN_STEPS="${REPLAN_STEPS}" \
  EVAL_PY="${EVAL_PY}" \
  TASKS2_26_BASE_EVAL_PY="${BASE_EVAL}" \
  TASK_CONFIG="${TASK_CONFIG}" \
  ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${OFFICIAL_SCRIPTS}" \
  ROBOMEMARENA_OFFICIAL_BDDL_DIR="${OFFICIAL_ROOT}/evaluation_benchmark/bddl" \
  ROBOMEMARENA_ROOT_BDDL_DIR="${OFFICIAL_ROOT}/bddl" \
  VLA_SERVER_PY="${PACK_DIR}/scripts/serve_policy_custom_repo.py" \
  VLA_ACTION_TARGET_MODE=raw \
  DISABLE_OUTPUT_NORMALIZE=1 \
  ENDPOSE_HOLD_TARGETS_JSON="${PACK_DIR}/config/task14_eef_targets.json" \
  ENDPOSE_TARGET_PASSAGE_COUNTS_JSON="${PACK_DIR}/config/task14_passage_counts.json" \
  ENDPOSE_HOLD_POS_TOL=0.06 \
  ENDPOSE_HOLD_EEF_DEFAULT_TOL=0.06 \
  ENDPOSE_HOLD_EEF_P95_EXTRA_TOL=0.02 \
  ENDPOSE_HOLD_EEF_TOL_CAP=0.08 \
  ENDPOSE_HOLD_MIN_ACTIVE_STEPS=20 \
  ENDPOSE_HOLD_CONSECUTIVE=2 \
  POST_HOLD_RELEASE_VLA_STEPS=30 \
  STRICT_HOLD_RELEASE_NEXT=0 \
  PREVENT_SUBTASK_REGRESSION=1 \
  REGRESSION_GUARD_AFTER_HOLD_RELEASE=1 \
  HOLD_RELEASE_BLOCK_PAST_SUBTASKS=0 \
  DRAWER_FORWARD_ADVANCE_GUARD=1 \
  DRAWER_OPEN_STAGE_THRESH=0.10 \
  DRAWER_CLOSE_STAGE_THRESH=0.08 \
  DRAWER_STAGE_DEBUG_INTERVAL=0 \
  ENDPOSE_PICK_GRIPPER_GATE=1 \
  ENDPOSE_PICK_OBJECT_LIFT_GATE=1 \
  ENDPOSE_PICK_OBJECT_LIFT_DELTA=0.01 \
  VLM_TASK_TEXT_MODE=english_reference_no_candidate \
  VLM_COMPLETED_SUBTASKS_MODE=completed_struct \
  SUBTASK_RELEASE_ANCHORS_JSON='' \
  ENDPOSE_HOLD_POS_TOL_BY_SUBTASK_FILE='' \
  ORACLE_HOLD_RELEASE_NEXT=0 \
  ORACLE_FORCE_INITIAL_PROMPT=0 \
  ORACLE_INITIAL_STAGE_LOCK=0 \
  ORACLE_STAGE_ADVANCE_NEXT=0 \
  ORACLE_MONOTONIC_SEQUENCE_LOCK=0 \
  ORACLE_STAGE_LOCK_UNTIL_DONE=0 \
  bash "${PACK_DIR}/evaluators/run_tasks2_26_sync_hold_eval_customrepo.sh"
