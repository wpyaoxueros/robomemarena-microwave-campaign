#!/usr/bin/env bash
set -euo pipefail

# Direct-use entrypoint for the archived Task1/3/25/26 packages.  It only
# materializes the recorded local asset environment, then delegates rollout
# and scoring to the already versioned d9 archived runner.

TASK_ID=${1:?usage: run_archived_direct20_single_gpu.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVED_CAMPAIGN="${CAMPAIGN_DIR}/../latest_openhelix_d9f83ac_exact20_20260725"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the campaign artifact root}
POST_GOAL_STEPS=${POST_GOAL_STEPS:-200}

case "${TASK_ID}" in
  1)
    VLM_CKPT=/data/user/hlei573/openpi_inference/tmp/vlm_eval_ready/task1_no_label_no_order_raw_regguard_ckpt1000_20ep_exact_seed104_20260701_090434/holdstatic_ckpt1000
    VLM_LABEL=task1_no_label_no_order_raw_regguard_ckpt1000_20ep_exact_seed104_20260701_090434
    ;;
  3)
    VLM_CKPT=/data/user/hlei573/openpi_inference/output/tasks2_26_noorder_ablation_eval_artifacts/vlm_eval_ready/task3_20260621_014805/task03_no_label_no_order_raw_regguard_ckpt500_ckpt500
    VLM_LABEL=task03_no_label_no_order_raw_regguard_ckpt500
    ;;
  25)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_0815_task25_enref_r3_holdearly_fixepscan/hzhang061/eval_artifacts/vlm_eval_ready/task25_task25_english_ref_20260624_080016_ckpt500_20260624_082818/task25_english_ref_20260624_080016_ckpt500
    VLM_LABEL=task25_english_ref_20260624_080016_ckpt500
    ;;
  26)
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_1402_task26_enref_r4_hardcase_lowstage/zzhang510/eval_artifacts/vlm_eval_ready/task26_task26_english_ref_20260624_155719_ckpt500_20260624_162536/task26_english_ref_20260624_155719_ckpt500
    VLM_LABEL=task26_english_ref_20260624_155719_ckpt500
    ;;
  *)
    echo "unsupported direct archived task: ${TASK_ID}" >&2
    exit 2
    ;;
esac

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose a GPU" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 1 ]] || {
  echo "direct single-GPU run requires one visible GPU, got ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

export OPENPI_ROOT=/data/user/hlei573/openpi
export INFER_ROOT=/data/user/hlei573/openpi_inference
export TARGET_LIBERO_PATH=/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork/libero
export OFFICIAL_ROOT=/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725
export VLA_POLICY=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
export VLA_NORM_FILE="${VLA_POLICY}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json"
export VLA_LABEL=fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
export VLM_CKPT VLM_LABEL OUTPUT_ROOT
export ARCHIVED_SYNC_RUNNER=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/run_tasks2_26_sync_hold_eval.sh
export ARCHIVED_TASKS_EVAL=/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_campaign_20260722/success_packs/repro20_remote_metrics_20260704_175011/evaluators/eval_tasks2_26_sync_endpose_hold_officialscore.py
export TASK1_RUNNER=/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_campaign_20260722/success_packs/repro20_remote_metrics_20260704_175011/evaluators/run_task1_officialscore.sh
export TASK1_EVAL=/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_campaign_20260722/success_packs/repro20_remote_metrics_20260704_175011/evaluators/eval_task1_qwen3_sync_endpose_hold_officialscore.py
export ENDPOSE_HOLD_TARGETS_JSON=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/tasks2_26_endpose_targets_seed100_199.json
export ENDPOSE_TARGET_PASSAGE_COUNTS_GENERAL=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/tasks2_26_target_passage_counts_seed100_199_alltasks_tol045_20260624_074452.json
export ENDPOSE_TARGET_PASSAGE_COUNTS_DRAWER=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/drawer_passage_counts_task4full_plus_alltasks_20260627.json

for required in \
  "${VLM_CKPT}" "${VLA_POLICY}" "${VLA_NORM_FILE}" "${OFFICIAL_ROOT}" \
  "${ARCHIVED_SYNC_RUNNER}" "${ARCHIVED_TASKS_EVAL}" "${TASK1_RUNNER}" \
  "${TASK1_EVAL}" "${ENDPOSE_HOLD_TARGETS_JSON}"; do
  [[ -e "${required}" ]] || { echo "missing recorded asset: ${required}" >&2; exit 3; }
done

mkdir -p "${OUTPUT_ROOT}/launch_records"
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task${TASK_ID}_all18_direct20_seed104_${STAMP}}
cat >"${OUTPUT_ROOT}/launch_records/${RUN_ID}.env" <<EOF
task_id=${TASK_ID}
run_id=${RUN_ID}
kind=all18_direct_archived_single_gpu
submitted_user=$(id -un)
slurm_job_id=${SLURM_JOB_ID}
remote_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
visible_gpu_before_remap=${CUDA_VISIBLE_DEVICES}
vla_binding=0
vlm_binding=0
vla_ckpt=${VLA_POLICY}
vlm_ckpt=${VLM_CKPT}
norm=${VLA_NORM_FILE}
post_goal_steps=${POST_GOAL_STEPS}
EOF

# A one-GPU Slurm allocation maps its only cgroup-visible device to index 0.
export CUDA_VISIBLE_DEVICES=0
export VLA_CUDA_VISIBLE_DEVICES=0
export VLM_CUDA_VISIBLE_DEVICES=0
export NUM_TRIALS=20
export SEED=104
export POST_GOAL_STEPS
export RUN_ID
export OUTPUT_ROOT_OVERRIDE="${OUTPUT_ROOT}"
export ARCHIVED_TASKS_EVAL_OVERRIDE="${ARCHIVED_CAMPAIGN}/adapters/eval_tasks2_26_sync_endpose_hold_d9_compat.py"

exec bash "${ARCHIVED_CAMPAIGN}/scripts/run_archived_task_exact20.sh" "${TASK_ID}"
