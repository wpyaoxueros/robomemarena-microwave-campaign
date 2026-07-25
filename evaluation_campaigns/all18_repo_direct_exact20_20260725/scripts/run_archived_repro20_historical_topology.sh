#!/usr/bin/env bash
set -euo pipefail

# Direct comparator for the original eight-task success package. It does not
# substitute the d9 campaign wrapper or alter the original two-GPU layout.

TASK_ID=${1:?usage: run_archived_repro20_historical_topology.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose GPUs" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 2 ]] || {
  echo "historical repro20 comparator requires exactly two visible GPUs, got ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/repro20_remote_metrics_20260704_175011
RUN_ONE="${SOURCE_ROOT}/run_one.sh"
TASK1_RUNNER="${SOURCE_ROOT}/evaluators/run_task1_officialscore.sh"
TASK1_EVAL="${SOURCE_ROOT}/evaluators/eval_task1_qwen3_sync_endpose_hold_officialscore.py"
TASKS_EVAL="${SOURCE_ROOT}/evaluators/eval_tasks2_26_sync_endpose_hold_officialscore.py"
OFFICIAL_COMMIT=66e7894f8188be8114911e5df0f8bf89fe4581ce
OFFICIAL_COMMIT_FILE="${SOURCE_ROOT}/official_remote_66e7894/REMOTE_COMMIT.txt"
OFFICIAL_STAGE="${SOURCE_ROOT}/official_remote_66e7894/evaluation_benchmark/scripts/task2_26_reference_stage.py"
HISTORICAL_LAUNCHER=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/run_tasks2_26_sync_hold_eval.sh
TARGETS=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/tasks2_26_endpose_targets_seed100_199.json
PASSAGE_GENERAL=/data/user/hlei573/openpi_inference/tmp/tasks2_26_holdstatic_general/tasks2_26_target_passage_counts_seed100_199_alltasks_tol045_20260624_074452.json
PASSAGE_DRAWER=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/drawer_passage_counts_task4full_plus_alltasks_20260627.json
VLA_CKPT=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLA_NORM="${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json"

case "${TASK_ID}" in
  1)
    VLM_ROLE=base_model_dir
    VLM_CKPT=/data/user/hlei573/openpi_inference/tmp/vlm_eval_ready/task1_no_label_no_order_raw_regguard_ckpt1000_20ep_exact_seed104_20260701_090434/holdstatic_ckpt1000
    ;;
  2)
    VLM_ROLE=vlm_ckpt
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task2_r1_exact20_eval_20260701_135219/vlm_eval_ready/task2_r1_ckpt500_20260701_143058
    ;;
  3)
    VLM_ROLE=vlm_ckpt
    VLM_CKPT=/data/user/hlei573/openpi_inference/output/tasks2_26_noorder_ablation_eval_artifacts/vlm_eval_ready/task3_20260621_014805/task03_no_label_no_order_raw_regguard_ckpt500_ckpt500
    ;;
  12)
    VLM_ROLE=vlm_ckpt
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task12_ckpt1000_exact20_completedstruct_parallel_20260701_193920_task12_ckpt1000_exact20_parallel/vlm_eval_ready/task12_seed104_borrow_20260701_1945/task12_english_ref_20260629_130504_exact20_completedstruct_seed104_ckpt1000
    ;;
  13)
    VLM_ROLE=vlm_ckpt
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_task13_task12style_completedstruct/hlei573/eval_artifacts/vlm_eval_ready/task13_task13_english_ref_20260702_113430_ckpt1000_20260702_123231/task13_english_ref_20260702_113430_ckpt1000
    ;;
  18)
    VLM_ROLE=vlm_ckpt
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_110452_task18_clean_completed_clean_task18_r9_clean_lateboundaries/hlei573/eval_artifacts/vlm_eval_ready/task18_20260702_130310_20ep_split_chunk0_seed104/task18_english_ref_20260702_110805_ckpt1000
    ;;
  25)
    VLM_ROLE=vlm_ckpt
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_0815_task25_enref_r3_holdearly_fixepscan/hzhang061/eval_artifacts/vlm_eval_ready/task25_task25_english_ref_20260624_080016_ckpt500_20260624_082818/task25_english_ref_20260624_080016_ckpt500
    ;;
  26)
    VLM_ROLE=vlm_ckpt
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_1402_task26_enref_r4_hardcase_lowstage/zzhang510/eval_artifacts/vlm_eval_ready/task26_task26_english_ref_20260624_155719_ckpt500_20260624_162536/task26_english_ref_20260624_155719_ckpt500
    ;;
  *)
    echo "unsupported historical repro20 task: ${TASK_ID}" >&2
    exit 2
    ;;
esac

check_sha() {
  local expected="$1"
  local path="$2"
  local actual
  actual="$(sha256sum "${path}" | awk '{print $1}')"
  [[ "${actual}" == "${expected}" ]] || {
    echo "historical source mismatch: path=${path} expected=${expected} actual=${actual}" >&2
    exit 3
  }
}

for required in \
  "${RUN_ONE}" "${TASK1_RUNNER}" "${TASK1_EVAL}" "${TASKS_EVAL}" \
  "${OFFICIAL_COMMIT_FILE}" "${OFFICIAL_STAGE}" "${HISTORICAL_LAUNCHER}" \
  "${TARGETS}" "${PASSAGE_GENERAL}" "${PASSAGE_DRAWER}" \
  "${VLA_CKPT}" "${VLA_NORM}" "${VLM_CKPT}"; do
  [[ -e "${required}" ]] || { echo "missing recorded asset: ${required}" >&2; exit 3; }
done

check_sha 70005b0564cedc38ac7ada01bdfdf82af49d7c170749acf5a8631026ac3b75b3 "${RUN_ONE}"
check_sha f4a7bd859042c1272907933dc0100ed911db1904551aedb4a75fe903df0c8ea1 "${TASK1_RUNNER}"
check_sha e89825f53cddd045a88aa1fb7cc7b4735e81abf8ff2479f0a05c0c149dcd1a59 "${TASK1_EVAL}"
check_sha ef95604ca17c7900eac172d0e082a3738ca5b62e8468bf4f53c522590ff7dd2b "${TASKS_EVAL}"
check_sha b02956ea062b13dfecef3900d9e9666f633717d77aef8b828d933ebb6c4dcf22 "${HISTORICAL_LAUNCHER}"
check_sha 8921ddbbda123ad419ac563397bb47ab95e3e696ee483c15d357f294beb5003d "${TARGETS}"
check_sha 4fb11fb0e440b42afd95674219ae007d75e29ae140f846d7221763987fbf54c6 "${PASSAGE_GENERAL}"
check_sha 09741b2c6fb1fac7a6cab776053e61e2b6791ec25208980ea83881fe786c512e "${PASSAGE_DRAWER}"
check_sha 4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a "${VLA_NORM}"
[[ "$(tr -d '[:space:]' < "${OFFICIAL_COMMIT_FILE}")" == "${OFFICIAL_COMMIT}" ]] || {
  echo "historical scorer commit file does not match ${OFFICIAL_COMMIT}" >&2
  exit 3
}
check_sha 5e3e20286d8dd77335bff28115a3a0a892cc435f8a8eeec176c3c56d6ac583d6 "${OFFICIAL_STAGE}"

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task${TASK_ID}_historical66e789_exact20_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/archived_repro20_historical/${RUN_ID}"
mkdir -p "${OUT_ROOT}/code_snapshot"

cp -p "${BASH_SOURCE[0]}" "${RUN_ONE}" "${TASK1_RUNNER}" "${TASK1_EVAL}" "${TASKS_EVAL}" \
  "${HISTORICAL_LAUNCHER}" "${OUT_ROOT}/code_snapshot/"
{
  printf 'task_id=%s\n' "${TASK_ID}"
  printf 'run_id=%s\n' "${RUN_ID}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID}"
  printf 'visible_gpu_topology=%s\n' "${CUDA_VISIBLE_DEVICES}"
  printf 'historical_vla_gpu=first-visible\n'
  printf 'historical_vlm_eval_gpu=second-visible\n'
  printf 'historical_scorer_commit=%s\n' "${OFFICIAL_COMMIT}"
  printf 'historical_stage_scorer_sha256=%s\n' "$(sha256sum "${OFFICIAL_STAGE}" | awk '{print $1}')"
  printf 'historical_source_root=%s\n' "${SOURCE_ROOT}"
  printf 'historical_run_one=%s\n' "${RUN_ONE}"
  printf 'historical_run_one_sha256=%s\n' "$(sha256sum "${RUN_ONE}" | awk '{print $1}')"
  printf 'historical_task_launcher=%s\n' "${HISTORICAL_LAUNCHER}"
  printf 'historical_task_launcher_sha256=%s\n' "$(sha256sum "${HISTORICAL_LAUNCHER}" | awk '{print $1}')"
  printf 'vla_ckpt=%s\n' "${VLA_CKPT}"
  printf 'vla_norm=%s\n' "${VLA_NORM}"
  printf 'vla_norm_sha256=%s\n' "$(sha256sum "${VLA_NORM}" | awk '{print $1}')"
  printf 'vlm_role=%s\n' "${VLM_ROLE}"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'num_trials=20\n'
  printf 'seed=104\n'
  printf 'max_steps=2000-default-or-task-specific-original\n'
  printf 'replan_steps=5-default-or-task-specific-original\n'
  printf 'campaign_git_commit=%s\n' "$(git -C "${REPO_DIR}" rev-parse HEAD)"
  printf 'modern_adapter=disabled\n'
} > "${OUT_ROOT}/historical_runtime_manifest.env"

# The original runner determines GPU 0/1 from the two GPUs Slurm exposes. Do
# not force device IDs or inject the current campaign's evaluator variables.
unset ARCHIVED_TASKS_EVAL_OVERRIDE ARCHIVED_TASKS_EVAL OFFICIAL_STAGE_MODULE
unset VLA_CUDA_VISIBLE_DEVICES VLM_CUDA_VISIBLE_DEVICES

exec env OFFICIAL_OUTPUT_ROOT="${OUT_ROOT}" OFFICIAL_RUN_STAMP="${RUN_ID}" \
  bash "${RUN_ONE}" "${TASK_ID}"
