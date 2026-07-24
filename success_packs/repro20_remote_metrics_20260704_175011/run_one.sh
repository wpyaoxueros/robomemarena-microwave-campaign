#!/usr/bin/env bash
set -euo pipefail

TASK_ID=${1:?usage: run_one.sh TASK_ID}
ROOT=${OFFICIAL_OUTPUT_ROOT:-/data/user/zzhang510/hlei573_borrow_outputs/repro20_official66e789_20260704_1815}
SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/repro20_remote_metrics_20260704_175011
INFER_ROOT=/data/user/hlei573/openpi_inference
VLA_POLICY=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLA_CONFIG=pi05_libero_robomemarena_fullvlm_v2_noflip_dataset
TARGETS=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/tasks2_26_endpose_targets_seed100_199.json
PASSAGE_GENERAL=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/tasks2_26_target_passage_counts_seed100_199_alltasks_tol045_20260624_074452.json
PASSAGE_DRAWER=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/drawer_passage_counts_task4full_plus_alltasks_20260627.json
RUNNER=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/run_tasks2_26_sync_hold_eval.sh
EVAL_PY=${SOURCE_ROOT}/evaluators/eval_tasks2_26_sync_endpose_hold_officialscore.py
OFFICIAL_SCRIPTS=${SOURCE_ROOT}/official_remote_66e7894/evaluation_benchmark/scripts
STAMP=${OFFICIAL_RUN_STAMP:-repro20_official66e789_20260704_1815}

mkdir -p "${ROOT}/task${TASK_ID}/code_snapshot"
mkdir -p "${ROOT}/task${TASK_ID}/code_snapshot/bddl"
cp -p "${SOURCE_ROOT}/run_one.sh" "${ROOT}/task${TASK_ID}/code_snapshot/run_one.sh"
cp -p "${OFFICIAL_SCRIPTS}"/*.py "${ROOT}/task${TASK_ID}/code_snapshot/"
cp -p "${SOURCE_ROOT}/official_remote_66e7894/evaluation_benchmark/bddl/${TASK_ID}_"*.bddl \
  "${ROOT}/task${TASK_ID}/code_snapshot/bddl/"
cp -p "${SOURCE_ROOT}/official_remote_66e7894/REMOTE_COMMIT.txt" "${ROOT}/task${TASK_ID}/code_snapshot/"

if [[ "${TASK_ID}" == "1" ]]; then
  RUN_ID=task1_exact20_remote_${STAMP}
  LOG_BASE=${ROOT}/task1
  RUN_ROOT=${LOG_BASE}/task1_sync/${RUN_ID}
  TASK1_RUNNER=${SOURCE_ROOT}/evaluators/run_task1_officialscore.sh
  TASK1_EVAL=${SOURCE_ROOT}/evaluators/eval_task1_qwen3_sync_endpose_hold_officialscore.py
  cp -p "${TASK1_RUNNER}" "${ROOT}/task1/code_snapshot/"
  cp -p "${TASK1_EVAL}" "${ROOT}/task1/code_snapshot/"
  env \
    RUN_ID="${RUN_ID}" \
    LOG_BASE="${LOG_BASE}" \
    EVAL_PY="${TASK1_EVAL}" \
    ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${OFFICIAL_SCRIPTS}" \
    PORT=8711 \
    BASE_MODEL_DIR=/data/user/hlei573/openpi_inference/tmp/vlm_eval_ready/task1_no_label_no_order_raw_regguard_ckpt1000_20ep_exact_seed104_20260701_090434/holdstatic_ckpt1000 \
    VLA_CONFIG="${VLA_CONFIG}" \
    VLA_POLICY="${VLA_POLICY}" \
    NUM_TRIALS_PER_TASK=20 \
    MAX_STEPS=2000 \
    REPLAN_STEPS=5 \
    SEED=104 \
    POST_HOLD_RELEASE_VLA_STEPS=30 \
    VLM_PROMPT_PROFILE=task1_no_label_no_order \
    PREVENT_SUBTASK_REGRESSION=1 \
    REGRESSION_GUARD_AFTER_HOLD_RELEASE=1 \
    TASK1_ACCEPT_RAW_VLM_OUTPUT=1 \
    TASK1_DISABLE_OUTPUT_NORMALIZE=1 \
    bash "${TASK1_RUNNER}"

  cp -p "${RUN_ROOT}/official_task_summary.tsv" "${ROOT}/task1/official_task_summary.tsv"
  exit 0
fi

ARTIFACT_ROOT=${ROOT}/task${TASK_ID}
RUN_ID=task${TASK_ID}_exact20_remote_${STAMP}
OUT_ROOT=${ARTIFACT_ROOT}/logs_task_sync_hold/${RUN_ID}
NUM_TRIALS=20
SEED=104
MAX_STEPS=2000
REPLAN_STEPS=5
PASSAGE_COUNTS=${PASSAGE_GENERAL}
DRAWER_GUARD=1
PICK_GRIPPER_GATE=1
PICK_LIFT_GATE=1
TEXT_MODE=english_reference_no_candidate
COMPLETED_MODE=off
PORT=$((8710 + TASK_ID))

case "${TASK_ID}" in
  2)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task2_r1_exact20_eval_20260701_135219/vlm_eval_ready/task2_r1_ckpt500_20260701_143058
    PASSAGE_COUNTS=__NONE__
    DRAWER_GUARD=0
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=0
    ;;
  3)
    VLM_CKPT=/data/user/hlei573/openpi_inference/output/tasks2_26_noorder_ablation_eval_artifacts/vlm_eval_ready/task3_20260621_014805/task03_no_label_no_order_raw_regguard_ckpt500_ckpt500
    PASSAGE_COUNTS=__NONE__
    DRAWER_GUARD=0
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=0
    TEXT_MODE=no_label_no_order
    ;;
  12)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task12_ckpt1000_exact20_completedstruct_parallel_20260701_193920_task12_ckpt1000_exact20_parallel/vlm_eval_ready/task12_seed104_borrow_20260701_1945/task12_english_ref_20260629_130504_exact20_completedstruct_seed104_ckpt1000
    MAX_STEPS=2200
    REPLAN_STEPS=10
    PASSAGE_COUNTS=${PASSAGE_DRAWER}
    COMPLETED_MODE=completed_struct
    ;;
  13)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_task13_task12style_completedstruct/hlei573/eval_artifacts/vlm_eval_ready/task13_task13_english_ref_20260702_113430_ckpt1000_20260702_123231/task13_english_ref_20260702_113430_ckpt1000
    MAX_STEPS=2200
    REPLAN_STEPS=10
    PASSAGE_COUNTS=${PASSAGE_DRAWER}
    COMPLETED_MODE=completed_struct
    ;;
  18)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_110452_task18_clean_completed_clean_task18_r9_clean_lateboundaries/hlei573/eval_artifacts/vlm_eval_ready/task18_20260702_130310_20ep_split_chunk0_seed104/task18_english_ref_20260702_110805_ckpt1000
    MAX_STEPS=2200
    PICK_GRIPPER_GATE=0
    PICK_LIFT_GATE=1
    ;;
  25)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_0815_task25_enref_r3_holdearly_fixepscan/hzhang061/eval_artifacts/vlm_eval_ready/task25_task25_english_ref_20260624_080016_ckpt500_20260624_082818/task25_english_ref_20260624_080016_ckpt500
    ;;
  26)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_1402_task26_enref_r4_hardcase_lowstage/zzhang510/eval_artifacts/vlm_eval_ready/task26_task26_english_ref_20260624_155719_ckpt500_20260624_162536/task26_english_ref_20260624_155719_ckpt500
    ;;
  *)
    echo "unsupported task: ${TASK_ID}" >&2
    exit 2
    ;;
esac

NUM_TRIALS=${OFFICIAL_NUM_TRIALS:-${NUM_TRIALS}}
SEED=${OFFICIAL_SEED:-${SEED}}
MAX_STEPS=${OFFICIAL_MAX_STEPS:-${MAX_STEPS}}
REPLAN_STEPS=${OFFICIAL_REPLAN_STEPS:-${REPLAN_STEPS}}

for required in "${VLM_CKPT}" "${VLA_POLICY}" "${TARGETS}" "${EVAL_PY}" "${RUNNER}"; do
  [[ -e "${required}" ]] || { echo "missing required path: ${required}" >&2; exit 3; }
done

cp -p "${EVAL_PY}" "${ARTIFACT_ROOT}/code_snapshot/"
cp -p "${RUNNER}" "${ARTIFACT_ROOT}/code_snapshot/"

export RUN_ID OUT_ROOT PORT VLM_CKPT VLA_CONFIG VLA_POLICY
export TASKS_JSON="[${TASK_ID}]" NUM_TRIALS SEED MAX_STEPS REPLAN_STEPS
export EVAL_PY ENDPOSE_HOLD_TARGETS_JSON=${TARGETS}
export ENDPOSE_TARGET_PASSAGE_COUNTS_JSON=${PASSAGE_COUNTS}
export ENDPOSE_HOLD_POS_TOL=0.06 ENDPOSE_HOLD_EEF_DEFAULT_TOL=0.06
export ENDPOSE_HOLD_EEF_P95_EXTRA_TOL=0.02 ENDPOSE_HOLD_EEF_TOL_CAP=0.08
export POST_HOLD_RELEASE_VLA_STEPS=30 STRICT_HOLD_RELEASE_NEXT=0
export PREVENT_SUBTASK_REGRESSION=1 REGRESSION_GUARD_AFTER_HOLD_RELEASE=1
export HOLD_RELEASE_BLOCK_PAST_SUBTASKS=0
export DRAWER_FORWARD_ADVANCE_GUARD=${DRAWER_GUARD}
export DRAWER_OPEN_STAGE_THRESH=0.10 DRAWER_CLOSE_STAGE_THRESH=0.08 DRAWER_STAGE_DEBUG_INTERVAL=0
export ENDPOSE_PICK_GRIPPER_GATE=${PICK_GRIPPER_GATE}
export ENDPOSE_PICK_OBJECT_LIFT_GATE=${PICK_LIFT_GATE} ENDPOSE_PICK_OBJECT_LIFT_DELTA=0.01
export DISABLE_OUTPUT_NORMALIZE=1 VLM_TASK_TEXT_MODE=${TEXT_MODE}
export VLM_COMPLETED_SUBTASKS_MODE=${COMPLETED_MODE}
export ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR=${OFFICIAL_SCRIPTS}

bash "${RUNNER}"
