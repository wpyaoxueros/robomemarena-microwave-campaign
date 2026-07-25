#!/usr/bin/env bash
set -euo pipefail

# Direct replay of the files saved by the original successful exact20 runs.
# The adapter only redirects absolute source paths to an immutable job-local
# copy of those files; it does not change rollout controls, model paths, or
# the two-GPU VLA/VLM topology.

TASK_ID=${1:?usage: run_archived_original_snapshot_topology.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
MATERIALIZER="${CAMPAIGN_DIR}/scripts/materialize_archived_original_execution_pack.py"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}
CAMPAIGN_GIT_COMMIT=${CAMPAIGN_GIT_COMMIT:?set CAMPAIGN_GIT_COMMIT before entering the compute node}
DRY_RUN=${FROZEN_SNAPSHOT_DRY_RUN:-0}

if [[ "${DRY_RUN}" != "1" ]]; then
  [[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
  [[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose GPUs" >&2; exit 2; }
  IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
  [[ ${#visible_gpus[@]} -eq 2 ]] || {
    echo "original snapshot replay requires exactly two visible GPUs, got ${CUDA_VISIBLE_DEVICES}" >&2
    exit 2
  }
fi

case "${TASK_ID}" in
  2)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task2_r1_exact20_eval_20260701_135219/vlm_eval_ready/task2_r1_ckpt500_20260701_143058
    MAX_STEPS=2000
    REPLAN_STEPS=5
    PASSAGE_MODE=none
    DRAWER_GUARD=0
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=0
    TEXT_MODE=english_reference_no_candidate
    COMPLETED_MODE=off
    ;;
  3)
    VLM_CKPT=/data/user/hlei573/openpi_inference/output/tasks2_26_noorder_ablation_eval_artifacts/vlm_eval_ready/task3_20260621_014805/task03_no_label_no_order_raw_regguard_ckpt500_ckpt500
    MAX_STEPS=2000
    REPLAN_STEPS=5
    PASSAGE_MODE=none
    DRAWER_GUARD=0
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=0
    TEXT_MODE=no_label_no_order
    COMPLETED_MODE=off
    ;;
  12)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task12_ckpt1000_exact20_completedstruct_parallel_20260701_193920_task12_ckpt1000_exact20_parallel/vlm_eval_ready/task12_seed104_borrow_20260701_1945/task12_english_ref_20260629_130504_exact20_completedstruct_seed104_ckpt1000
    MAX_STEPS=2200
    REPLAN_STEPS=10
    PASSAGE_MODE=snapshot
    DRAWER_GUARD=1
    PICK_GRIPPER_GATE=1
    PICK_LIFT_GATE=1
    TEXT_MODE=english_reference_no_candidate
    COMPLETED_MODE=completed_struct
    ;;
  13)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_task13_task12style_completedstruct/hlei573/eval_artifacts/vlm_eval_ready/task13_task13_english_ref_20260702_113430_ckpt1000_20260702_123231/task13_english_ref_20260702_113430_ckpt1000
    MAX_STEPS=2200
    REPLAN_STEPS=10
    PASSAGE_MODE=snapshot
    DRAWER_GUARD=1
    PICK_GRIPPER_GATE=1
    PICK_LIFT_GATE=1
    TEXT_MODE=english_reference_no_candidate
    COMPLETED_MODE=completed_struct
    ;;
  18)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_110452_task18_clean_completed_clean_task18_r9_clean_lateboundaries/hlei573/eval_artifacts/vlm_eval_ready/task18_20260702_130310_20ep_split_chunk0_seed104/task18_english_ref_20260702_110805_ckpt1000
    MAX_STEPS=2200
    REPLAN_STEPS=5
    PASSAGE_MODE=snapshot
    DRAWER_GUARD=1
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=1
    TEXT_MODE=english_reference_no_candidate
    COMPLETED_MODE=off
    ;;
  25)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_0815_task25_enref_r3_holdearly_fixepscan/hzhang061/eval_artifacts/vlm_eval_ready/task25_task25_english_ref_20260624_080016_ckpt500_20260624_082818/task25_english_ref_20260624_080016_ckpt500
    MAX_STEPS=2000
    REPLAN_STEPS=5
    PASSAGE_MODE=snapshot
    DRAWER_GUARD=1
    PICK_GRIPPER_GATE=1
    PICK_LIFT_GATE=1
    TEXT_MODE=english_reference_no_candidate
    COMPLETED_MODE=off
    ;;
  26)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_1402_task26_enref_r4_hardcase_lowstage/zzhang510/eval_artifacts/vlm_eval_ready/task26_task26_english_ref_20260624_155719_ckpt500_20260624_162536/task26_english_ref_20260624_155719_ckpt500
    MAX_STEPS=2000
    REPLAN_STEPS=5
    PASSAGE_MODE=snapshot
    DRAWER_GUARD=1
    PICK_GRIPPER_GATE=1
    PICK_LIFT_GATE=1
    TEXT_MODE=english_reference_no_candidate
    COMPLETED_MODE=off
    ;;
  *)
    echo "unsupported archived original snapshot task: ${TASK_ID}" >&2
    exit 2
    ;;
esac

VLA_CKPT=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLA_NORM="${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json"
VLA_CONFIG=pi05_libero_robomemarena_fullvlm_v2_noflip_dataset

[[ -x "$(command -v python3)" ]] || { echo "python3 is required" >&2; exit 2; }
[[ -x "${MATERIALIZER}" || -f "${MATERIALIZER}" ]] || { echo "missing materializer: ${MATERIALIZER}" >&2; exit 2; }
[[ -e "${VLM_CKPT}" && -e "${VLA_CKPT}" && -f "${VLA_NORM}" ]] || {
  echo "missing VLM, VLA, or norm asset" >&2
  exit 3
}

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
if [[ "${DRY_RUN}" == "1" ]]; then
  STAMP=dryrun
fi
RUN_ID=${RUN_ID:-task${TASK_ID}_originalsnapshot66e789_exact20_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/archived_original_snapshot/${RUN_ID}"
EXECUTION_PACK="${OUT_ROOT}/execution_pack"
mkdir -p "${OUT_ROOT}"

python3 "${MATERIALIZER}" --task-id "${TASK_ID}" --output "${EXECUTION_PACK}"

FROZEN_CODE="${EXECUTION_PACK}/code_snapshot"
FROZEN_REPRO="${EXECUTION_PACK}/repro_snapshot/files"
FROZEN_LAUNCHER="${FROZEN_CODE}/run_tasks2_26_sync_hold_eval.sh"
FROZEN_EVALUATOR="${EXECUTION_PACK}/driver/eval_tasks2_26_sync_endpose_hold_officialscore.py"
FROZEN_BASE_EVALUATOR="${EXECUTION_PACK}/RoboMemArena/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py"
FROZEN_OFFICIAL_SCRIPTS="${EXECUTION_PACK}/RoboMemArena/evaluation_benchmark/scripts"
FROZEN_TASK_CONFIG="${FROZEN_REPRO}/task_config__fullvlm_v2_26_memory_tasks.json"
FROZEN_TARGETS="${FROZEN_REPRO}/endpose_hold_targets__tasks2_26_endpose_targets_seed100_199.json"
FROZEN_PASSAGES="${FROZEN_REPRO}/passage_counts__tasks2_26_target_passage_counts_seed100_199_alltasks_tol045_20260624_074452.json"

for required in "${FROZEN_LAUNCHER}" "${FROZEN_EVALUATOR}" "${FROZEN_BASE_EVALUATOR}" "${FROZEN_OFFICIAL_SCRIPTS}/eval_common.py" "${FROZEN_OFFICIAL_SCRIPTS}/task2_26_reference_stage.py" "${FROZEN_TASK_CONFIG}" "${FROZEN_TARGETS}"; do
  [[ -f "${required}" ]] || { echo "missing frozen runtime asset: ${required}" >&2; exit 3; }
done
if [[ "${PASSAGE_MODE}" == snapshot ]]; then
  [[ -f "${FROZEN_PASSAGES}" ]] || { echo "missing frozen passage counts: ${FROZEN_PASSAGES}" >&2; exit 3; }
  PASSAGE_COUNTS="${FROZEN_PASSAGES}"
else
  PASSAGE_COUNTS=__NONE__
fi

sha256() {
  sha256sum "$1" | awk '{print $1}'
}

{
  printf 'task_id=%s\n' "${TASK_ID}"
  printf 'run_id=%s\n' "${RUN_ID}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID:-dryrun}"
  printf 'visible_gpu_topology=%s\n' "${CUDA_VISIBLE_DEVICES:-dryrun}"
  printf 'historical_vla_gpu=first-visible\n'
  printf 'historical_vlm_eval_gpu=second-visible\n'
  printf 'num_trials=20\n'
  printf 'seed=104\n'
  printf 'max_steps=%s\n' "${MAX_STEPS}"
  printf 'replan_steps=%s\n' "${REPLAN_STEPS}"
  printf 'passage_counts=%s\n' "${PASSAGE_COUNTS}"
  printf 'drawer_forward_advance_guard=%s\n' "${DRAWER_GUARD}"
  printf 'pick_gripper_gate=%s\n' "${PICK_GRIPPER_GATE}"
  printf 'pick_lift_gate=%s\n' "${PICK_LIFT_GATE}"
  printf 'vlm_task_text_mode=%s\n' "${TEXT_MODE}"
  printf 'completed_subtasks_mode=%s\n' "${COMPLETED_MODE}"
  printf 'vla_ckpt=%s\n' "${VLA_CKPT}"
  printf 'vla_norm=%s\n' "${VLA_NORM}"
  printf 'vla_norm_sha256=%s\n' "$(sha256 "${VLA_NORM}")"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'frozen_launcher=%s\n' "${FROZEN_LAUNCHER}"
  printf 'frozen_launcher_sha256=%s\n' "$(sha256 "${FROZEN_LAUNCHER}")"
  printf 'frozen_evaluator=%s\n' "${FROZEN_EVALUATOR}"
  printf 'frozen_evaluator_sha256=%s\n' "$(sha256 "${FROZEN_EVALUATOR}")"
  printf 'frozen_base_evaluator=%s\n' "${FROZEN_BASE_EVALUATOR}"
  printf 'frozen_base_evaluator_sha256=%s\n' "$(sha256 "${FROZEN_BASE_EVALUATOR}")"
  printf 'frozen_official_scripts_dir=%s\n' "${FROZEN_OFFICIAL_SCRIPTS}"
  printf 'frozen_task_config=%s\n' "${FROZEN_TASK_CONFIG}"
  printf 'frozen_targets=%s\n' "${FROZEN_TARGETS}"
  printf 'frozen_official_scripts_dir=%s\n' "${FROZEN_CODE}"
  printf 'execution_pack_manifest=%s\n' "${EXECUTION_PACK}/execution_pack_manifest.json"
  printf 'campaign_git_commit=%s\n' "${CAMPAIGN_GIT_COMMIT}"
  printf 'modern_adapter=disabled\n'
} > "${OUT_ROOT}/original_snapshot_runtime_plan.env"

if [[ "${DRY_RUN}" == "1" ]]; then
  cat "${OUT_ROOT}/original_snapshot_runtime_plan.env"
  exit 0
fi

# Prevent a caller's newer evaluator controls from leaking into the frozen path.
unset ARCHIVED_TASKS_EVAL_OVERRIDE ARCHIVED_TASKS_EVAL OFFICIAL_STAGE_MODULE
unset OFFICIAL_NUM_TRIALS OFFICIAL_SEED OFFICIAL_MAX_STEPS OFFICIAL_REPLAN_STEPS
unset VLA_CUDA_VISIBLE_DEVICES VLM_CUDA_VISIBLE_DEVICES STAGE_DONE_HOLD_FOR_POUR

export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=safe.directory
export GIT_CONFIG_VALUE_0="${REPO_DIR}"

exec env \
  RUN_ID="${RUN_ID}" \
  OUT_ROOT="${OUT_ROOT}" \
  PORT="$((8710 + TASK_ID))" \
  VLM_CKPT="${VLM_CKPT}" \
  VLA_CONFIG="${VLA_CONFIG}" \
  VLA_POLICY="${VLA_CKPT}" \
  TASKS_JSON="[${TASK_ID}]" \
  NUM_TRIALS=20 \
  SEED=104 \
  MAX_STEPS="${MAX_STEPS}" \
  REPLAN_STEPS="${REPLAN_STEPS}" \
  EVAL_PY="${FROZEN_EVALUATOR}" \
  TASKS2_26_BASE_EVAL_PY="${FROZEN_BASE_EVALUATOR}" \
  TASK_CONFIG="${FROZEN_TASK_CONFIG}" \
  ENDPOSE_HOLD_TARGETS_JSON="${FROZEN_TARGETS}" \
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
  DRAWER_STAGE_DEBUG_INTERVAL=0 \
  ENDPOSE_PICK_GRIPPER_GATE="${PICK_GRIPPER_GATE}" \
  ENDPOSE_PICK_OBJECT_LIFT_GATE="${PICK_LIFT_GATE}" \
  ENDPOSE_PICK_OBJECT_LIFT_DELTA=0.01 \
  DISABLE_OUTPUT_NORMALIZE=1 \
  VLM_TASK_TEXT_MODE="${TEXT_MODE}" \
  VLM_COMPLETED_SUBTASKS_MODE="${COMPLETED_MODE}" \
  ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${FROZEN_OFFICIAL_SCRIPTS}" \
  REPRO_SNAPSHOT_LAUNCHER="${FROZEN_LAUNCHER}" \
  bash "${FROZEN_LAUNCHER}"
