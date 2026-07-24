#!/usr/bin/env bash
set -euo pipefail

# The frozen packages remain untouched. This runner generates a job-local
# overlay that only changes the VLA, VLM, and EGL device bindings to 0.

TASK_ID=${1:?usage: run_counting_direct20_single_gpu.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose a GPU" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 1 ]] || {
  echo "single-GPU direct runner requires one visible device, got ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725
OPENPI_ROOT=/data/user/hlei573/openpi
OPENPI_INFERENCE_ROOT=/data/user/hlei573/openpi_inference
VLA_CKPT=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
TARGET_LIBERO_PATH=/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork
EXPECTED_SCORER_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538

case "${TASK_ID}" in
  6)
    FROZEN_PACK_DIR="${REPO_DIR}/counting/task6_fixed_seed_latest_d9f83ac"
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260621_181347/hlei/eval_artifacts/vlm_eval_ready/task6_task06_english_ref_20260621_192534_ckpt1000_20260621_202035/task06_english_ref_20260621_192534_ckpt1000
    MODE=fixed-seed-repeat
    SEED=100
    PORT=29606
    ;;
  7)
    FROZEN_PACK_DIR="${REPO_DIR}/counting/task7_vlm35999_latest_d9f83ac_hardcase500_20260724"
    VLM_CKPT=/data/user/zzhang510/hlei573_borrow_outputs/counting_task7_evalpour1hardcase256aligned_vlm_2gpu_acdu_20260724_093053/vlm_eval_ready/checkpoint-500
    MODE=twenty-episode
    SEED=100
    PORT=29607
    ;;
  10)
    FROZEN_PACK_DIR="${REPO_DIR}/counting/task10_vlm35999_d9f83ac_pourreturnassist_20260724"
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/repro_eval_packs/counting_vlm35999_latest_d9f83ac_2ep_20260723/evidence/training/task10_pickpour1_pour2_boundary_vlm_20260724_052511/checkpoint-750
    MODE=twenty-episode
    SEED=100
    PORT=29610
    ;;
  16)
    FROZEN_PACK_DIR="${REPO_DIR}/counting/task16_vlm35999_d9f83ac_pourreturnassist_20260724"
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/repro_eval_packs/counting_vlm35999_latest_d9f83ac_2ep_20260723/runs_stageprompt/training_task16_pick_postlift_balanced_vlm_20260724_201612_emergency_acd/checkpoint-100
    MODE=twenty-episode
    SEED=100
    PORT=29616
    ;;
  *)
    echo "unsupported counting task: ${TASK_ID}" >&2
    exit 2
    ;;
esac

SCORER_FILE="${SOURCE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py"
for required in \
  "${FROZEN_PACK_DIR}" "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh" \
  "${VLM_CKPT}/model.safetensors" "${VLA_CKPT}" \
  "${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json" \
  "${SOURCE_ROOT}" "${SCORER_FILE}" "${TARGET_LIBERO_PATH}"; do
  [[ -e "${required}" ]] || { echo "missing recorded asset: ${required}" >&2; exit 3; }
done
actual_scorer_sha="$(sha256sum "${SCORER_FILE}" | awk '{print $1}')"
[[ "${actual_scorer_sha}" == "${EXPECTED_SCORER_SHA}" ]] || {
  echo "scorer mismatch: ${actual_scorer_sha}" >&2
  exit 3
}

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task${TASK_ID}_all18_direct20_single_gpu_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/task${TASK_ID}/${RUN_ID}"
OVERLAY_RUNNER="${OUT_ROOT}/code_snapshot/run_autonomous_task_single_gpu_overlay.sh"
EVALUATOR_OVERLAY_ROOT="${OUT_ROOT}/evaluator_overlay"
mkdir -p "${OUT_ROOT}/code_snapshot"
python3 "${CAMPAIGN_DIR}/scripts/build_counting_single_gpu_overlay.py" \
  --source "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh" \
  --output "${OVERLAY_RUNNER}" | tee "${OUT_ROOT}/overlay_build.txt"
python3 "${CAMPAIGN_DIR}/scripts/materialize_counting_evaluator_overlay.py" \
  --frozen-pack "${FROZEN_PACK_DIR}" \
  --source-root "${SOURCE_ROOT}" \
  --output "${EVALUATOR_OVERLAY_ROOT}" | tee "${OUT_ROOT}/evaluator_overlay_build.txt"
cp -p "${CAMPAIGN_DIR}/scripts/run_counting_direct20_single_gpu.sh" "${OUT_ROOT}/code_snapshot/"
cp -p "${CAMPAIGN_DIR}/scripts/build_counting_single_gpu_overlay.py" "${OUT_ROOT}/code_snapshot/"
cp -p "${CAMPAIGN_DIR}/scripts/materialize_counting_evaluator_overlay.py" "${OUT_ROOT}/code_snapshot/"

{
  printf 'task_id=%s\n' "${TASK_ID}"
  printf 'run_id=%s\n' "${RUN_ID}"
  printf 'mode=%s\n' "${MODE}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID}"
  printf 'remote_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1\n'
  printf 'remote_scorer_sha256=%s\n' "${actual_scorer_sha}"
  printf 'frozen_pack=%s\n' "${FROZEN_PACK_DIR}"
  printf 'frozen_runner_sha256=%s\n' "$(sha256sum "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh" | awk '{print $1}')"
  printf 'evaluator_overlay_root=%s\n' "${EVALUATOR_OVERLAY_ROOT}"
  printf 'evaluator_overlay_manifest_sha256=%s\n' "$(sha256sum "${EVALUATOR_OVERLAY_ROOT}/overlay_manifest.json" | awk '{print $1}')"
  printf 'overlay_runner=%s\n' "${OVERLAY_RUNNER}"
  printf 'overlay_runner_sha256=%s\n' "$(sha256sum "${OVERLAY_RUNNER}" | awk '{print $1}')"
  printf 'vla_ckpt=%s\n' "${VLA_CKPT}"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'norm=%s\n' "${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json"
  printf 'cuda_visible_devices_before_remap=%s\n' "${CUDA_VISIBLE_DEVICES}"
  printf 'vla_cuda_visible_devices=0\n'
  printf 'vlm_cuda_visible_devices=0\n'
  printf 'mujoco_egl_device_id=0\n'
} >"${OUT_ROOT}/direct20_manifest.env"

FROZEN_PACK_DIR="${EVALUATOR_OVERLAY_ROOT}"
export SOURCE_ROOT OPENPI_ROOT OPENPI_INFERENCE_ROOT TARGET_LIBERO_PATH
export VLA_CKPT VLM_CKPT FROZEN_PACK_DIR
export PACKAGE_GIT_DIR="${REPO_DIR}"
export VLA_CUDA_VISIBLE_DEVICES=0
export VLM_CUDA_VISIBLE_DEVICES=0
export MUJOCO_EGL_DEVICE_ID=0
export CUDA_VISIBLE_DEVICES=0
export RUNTIME_HOME="${RUNTIME_HOME:-${HOME}}"

if [[ "${MODE}" == "fixed-seed-repeat" ]]; then
  RUNNER="${OVERLAY_RUNNER}" \
  RUN_GROUP="${RUN_ID}" \
  WORKER_ID=0 \
  REPEAT_START=0 \
  REPEAT_COUNT=20 \
  FIXED_SEED="${SEED}" \
  RUNS_BASE="${OUT_ROOT}/workers/worker0" \
  LOG_DIR="${OUT_ROOT}/logs" \
  BASE_PORT="${PORT}" \
  bash "${EVALUATOR_OVERLAY_ROOT}/scripts/run_task6_fixed_seed_repeat_worker.sh"
  exit 0
fi

case "${TASK_ID}" in
  7)
    TASK_ID=7 NUM_TRIALS=20 SEED="${SEED}" REPLAN_STEPS=5 POST_STAGE_STEPS=30 \
    VLM_INTERVAL=25 HOLD_AFTER_REQUIRED_STAGES=0 \
    EVALUATOR_FILE_OVERRIDE="${EVALUATOR_OVERLAY_ROOT}/evaluators/eval_counting_autonomous_guarded_d9f83ac.py" \
    PORT="${PORT}" RUN_ID="${RUN_ID}" OUT_ROOT="${OUT_ROOT}" bash "${OVERLAY_RUNNER}"
    ;;
  10)
    TASK_ID=10 NUM_TRIALS=20 SEED="${SEED}" VLA_POLICY_SEED=100 REPLAN_STEPS=1 \
    POST_STAGE_STEPS=30 VLM_INTERVAL=25 HOLD_AFTER_REQUIRED_STAGES=1 \
    STAGE_LATCH_AUTONOMOUS_HOLD=0 PROMPT_NO_REGRESSION=1 \
    POUR_RETURN_ASSIST=0 TASK10_POUR_RETURN_ASSIST=1 \
    TASK10_POUR_RETURN_ASSIST_TARGET_RADIUS=0.20 \
    TASK10_POUR_RETURN_ASSIST_ROTATION_MAGNITUDE=0.8 \
    TASK10_POUR_RETURN_ASSIST_MAX_STEPS=24 \
    ORACLE_FORCE_INITIAL_PROMPT=0 ORACLE_HOLD_RELEASE_NEXT=0 \
    ORACLE_STAGE_ADVANCE_NEXT=0 ORACLE_TASK8_PICK_AFTER_PLACE_STEPS=-1 \
    EVALUATOR_FILE_OVERRIDE="${EVALUATOR_OVERLAY_ROOT}/evaluators/eval_counting_task10_pour_return_assist_d9f83ac.py" \
    PORT="${PORT}" RUN_ID="${RUN_ID}" OUT_ROOT="${OUT_ROOT}" bash "${OVERLAY_RUNNER}"
    ;;
  16)
    TASK_ID=16 NUM_TRIALS=20 SEED="${SEED}" VLA_POLICY_SEED=100 REPLAN_STEPS=1 \
    POST_STAGE_STEPS=30 VLM_INTERVAL=25 HOLD_AFTER_REQUIRED_STAGES=1 \
    STAGE_LATCH_AUTONOMOUS_HOLD=0 PROMPT_NO_REGRESSION=1 \
    POUR_RETURN_ASSIST=1 POUR_RETURN_ASSIST_TARGET_RADIUS=0.20 \
    POUR_RETURN_ASSIST_ROTATION_MAGNITUDE=0.8 POUR_RETURN_ASSIST_MAX_STEPS=24 \
    ORACLE_FORCE_INITIAL_PROMPT=0 ORACLE_HOLD_RELEASE_NEXT=0 \
    ORACLE_STAGE_ADVANCE_NEXT=0 ORACLE_TASK8_PICK_AFTER_PLACE_STEPS=-1 \
    EVALUATOR_FILE_OVERRIDE="${EVALUATOR_OVERLAY_ROOT}/evaluators/eval_counting_autonomous_pour_return_assist_d9f83ac.py" \
    PORT="${PORT}" RUN_ID="${RUN_ID}" OUT_ROOT="${OUT_ROOT}" bash "${OVERLAY_RUNNER}"
    ;;
esac
