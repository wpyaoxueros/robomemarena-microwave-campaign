#!/usr/bin/env bash
set -euo pipefail

# Run the frozen Task6/Task16 packages without the campaign's single-GPU
# overlay. The source packages themselves bind VLA to the first visible GPU
# and the VLM/evaluator to the second visible GPU.

TASK_ID=${1:?usage: run_counting_historical_two_gpu.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}
CAMPAIGN_GIT_COMMIT=${CAMPAIGN_GIT_COMMIT:?set CAMPAIGN_GIT_COMMIT before entering the compute node}

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose GPUs" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 2 ]] || {
  echo "historical counting comparator requires exactly two visible GPUs, got ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725
OPENPI_ROOT=/data/user/hlei573/openpi
OPENPI_INFERENCE_ROOT=/data/user/hlei573/openpi_inference
TARGET_LIBERO_PATH=/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork
VLA_CKPT=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLA_NORM="${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json"
SCORER_FILE="${SOURCE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py"
OFFICIAL_EVALUATOR_FILE="${SOURCE_ROOT}/evaluation_benchmark/async_vlm26_reference/eval_fullvlm26_async_vlm_vla.py"
EXPECTED_SCORER_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538
EXPECTED_OFFICIAL_EVALUATOR_SHA=b19cb0afa7fe1c9044495d7aeb57dccc754cdca60fe075eadfe8d667f1974fb9
EXPECTED_NORM_SHA=4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a

case "${TASK_ID}" in
  6)
    FROZEN_PACK_DIR="${REPO_DIR}/counting/task6_fixed_seed_latest_d9f83ac"
    FROZEN_ENTRYPOINT="${FROZEN_PACK_DIR}/scripts/run_task6_fixed_seed_repeat_worker.sh"
    FROZEN_RUNNER="${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh"
    FROZEN_EVALUATOR="${FROZEN_PACK_DIR}/evaluators/eval_counting_autonomous_guarded_d9f83ac.py"
    FROZEN_SERVER="${FROZEN_PACK_DIR}/scripts/serve_policy_selfcontained.py"
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260621_181347/hlei/eval_artifacts/vlm_eval_ready/task6_task06_english_ref_20260621_192534_ckpt1000_20260621_202035/task06_english_ref_20260621_192534_ckpt1000
    EXPECTED_ENTRYPOINT_SHA=d5c3574a515a8cca2d54d14645efbc652ce9abb773d5571672db27800bdacbb6
    EXPECTED_RUNNER_SHA=a6527351b3a65f6096a07e443daffb760928482bec8c9e3d78991113af63c559
    EXPECTED_EVALUATOR_SHA=23e55b335346eca5a1d608a519eb85e9ca7f64ba9c8cae660bc90416f6cc0167
    EXPECTED_SERVER_SHA=dd2e70c77fcd4bf5263dc425a802c8fc7273435857a03f9bbfbbd06263fd7914
    MODE=fixed-seed-repeat
    DEFAULT_SEED=100
    ;;
  16)
    FROZEN_PACK_DIR="${REPO_DIR}/counting/task16_vlm35999_d9f83ac_pourreturnassist_20260724"
    FROZEN_ENTRYPOINT="${FROZEN_PACK_DIR}/run_task16_29ep.sh"
    FROZEN_RUNNER="${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh"
    FROZEN_EVALUATOR="${FROZEN_PACK_DIR}/evaluators/eval_counting_autonomous_pour_return_assist_d9f83ac.py"
    FROZEN_SERVER="${FROZEN_PACK_DIR}/scripts/serve_policy_selfcontained.py"
    VLM_CKPT=/data/user/hlei573/vla_memory_experiments/repro_eval_packs/counting_vlm35999_latest_d9f83ac_2ep_20260723/runs_stageprompt/training_task16_pick_postlift_balanced_vlm_20260724_201612_emergency_acd/checkpoint-100
    EXPECTED_ENTRYPOINT_SHA=7b2b72391fb3e48b70633af4fd222ce01b674ac724d499d6693e5ed7a1a9f82f
    EXPECTED_RUNNER_SHA=5dfff914c4bbd286e8b3f2b5f556e521fb38682b2afb13b239f297f917c6149d
    EXPECTED_EVALUATOR_SHA=c38e7335012e29633d3d8e8096852a534d610ac2dc201539f26708a32a0388d0
    EXPECTED_SERVER_SHA=91b22fc948bcd9d7175ed709a07d31ab1f542a96f3e22af85fbb3bf90e27c9cf
    MODE=seed-range
    DEFAULT_SEED=100
    ;;
  *)
    echo "unsupported frozen counting task: ${TASK_ID}" >&2
    exit 2
    ;;
esac

check_sha() {
  local expected="$1"
  local path="$2"
  local actual
  actual="$(sha256sum "${path}" | awk '{print $1}')"
  [[ "${actual}" == "${expected}" ]] || {
    echo "frozen source mismatch: path=${path} expected=${expected} actual=${actual}" >&2
    exit 3
  }
}

for required in \
  "${SOURCE_ROOT}" "${OPENPI_ROOT}" "${OPENPI_INFERENCE_ROOT}" "${TARGET_LIBERO_PATH}" \
  "${SCORER_FILE}" "${OFFICIAL_EVALUATOR_FILE}" "${VLA_CKPT}" "${VLA_NORM}" \
  "${FROZEN_ENTRYPOINT}" "${FROZEN_RUNNER}" "${FROZEN_EVALUATOR}" "${FROZEN_SERVER}" \
  "${VLM_CKPT}/model.safetensors"; do
  [[ -e "${required}" ]] || { echo "missing recorded asset: ${required}" >&2; exit 3; }
done

check_sha "${EXPECTED_SCORER_SHA}" "${SCORER_FILE}"
check_sha "${EXPECTED_OFFICIAL_EVALUATOR_SHA}" "${OFFICIAL_EVALUATOR_FILE}"
check_sha "${EXPECTED_NORM_SHA}" "${VLA_NORM}"
check_sha "${EXPECTED_ENTRYPOINT_SHA}" "${FROZEN_ENTRYPOINT}"
check_sha "${EXPECTED_RUNNER_SHA}" "${FROZEN_RUNNER}"
check_sha "${EXPECTED_EVALUATOR_SHA}" "${FROZEN_EVALUATOR}"
check_sha "${EXPECTED_SERVER_SHA}" "${FROZEN_SERVER}"

# The submit account does not own the shared worktree. Make git metadata
# readable for the frozen packages without changing the account-global config.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=safe.directory
export GIT_CONFIG_VALUE_0="${REPO_DIR}"

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task${TASK_ID}_historical_d9f83ac_exact20_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/counting_historical_two_gpu/${RUN_ID}"
EXECUTION_PACK="${OUT_ROOT}/execution_pack"
PORT=${PORT:-$((29860 + TASK_ID))}
SEED=${SEED:-${DEFAULT_SEED}}
mkdir -p "${OUT_ROOT}/code_snapshot" "${OUT_ROOT}/logs"
cp -p "${BASH_SOURCE[0]}" "${FROZEN_ENTRYPOINT}" "${FROZEN_RUNNER}" \
  "${FROZEN_EVALUATOR}" "${FROZEN_SERVER}" "${OUT_ROOT}/code_snapshot/"

# The frozen counting evaluators resolve their official evaluator relative to
# PACK_DIR/source/RoboMemArena_d9f83ac. Preserve that original code contract in
# a job-local copy and point only the expected source path at the pinned d9
# checkout. No evaluator source, model asset, scorer, or device binding changes.
cp -a "${FROZEN_PACK_DIR}" "${EXECUTION_PACK}"
mkdir -p "${EXECUTION_PACK}/source"
ln -s "${SOURCE_ROOT}" "${EXECUTION_PACK}/source/RoboMemArena_d9f83ac"
[[ "$(readlink "${EXECUTION_PACK}/source/RoboMemArena_d9f83ac")" == "${SOURCE_ROOT}" ]] || {
  echo "execution-pack official source link does not target the pinned source root" >&2
  exit 3
}
ENTRYPOINT_REL="${FROZEN_ENTRYPOINT#${FROZEN_PACK_DIR}/}"
RUNNER_REL="${FROZEN_RUNNER#${FROZEN_PACK_DIR}/}"
EVALUATOR_REL="${FROZEN_EVALUATOR#${FROZEN_PACK_DIR}/}"
SERVER_REL="${FROZEN_SERVER#${FROZEN_PACK_DIR}/}"
EXECUTION_ENTRYPOINT="${EXECUTION_PACK}/${ENTRYPOINT_REL}"
EXECUTION_RUNNER="${EXECUTION_PACK}/${RUNNER_REL}"
EXECUTION_EVALUATOR="${EXECUTION_PACK}/${EVALUATOR_REL}"
EXECUTION_SERVER="${EXECUTION_PACK}/${SERVER_REL}"
check_sha "${EXPECTED_ENTRYPOINT_SHA}" "${EXECUTION_ENTRYPOINT}"
check_sha "${EXPECTED_RUNNER_SHA}" "${EXECUTION_RUNNER}"
check_sha "${EXPECTED_EVALUATOR_SHA}" "${EXECUTION_EVALUATOR}"
check_sha "${EXPECTED_SERVER_SHA}" "${EXECUTION_SERVER}"

{
  printf 'task_id=%s\n' "${TASK_ID}"
  printf 'run_id=%s\n' "${RUN_ID}"
  printf 'mode=%s\n' "${MODE}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID}"
  printf 'visible_gpu_topology=%s\n' "${CUDA_VISIBLE_DEVICES}"
  printf 'vla_cuda_visible_devices=0\n'
  printf 'vlm_eval_cuda_visible_devices=1\n'
  printf 'vlm_device_inside_eval=cuda:0\n'
  printf 'mujoco_egl_device_id=1\n'
  printf 'remote_scorer_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1\n'
  printf 'remote_scorer_sha256=%s\n' "$(sha256sum "${SCORER_FILE}" | awk '{print $1}')"
  printf 'official_evaluator_sha256=%s\n' "$(sha256sum "${OFFICIAL_EVALUATOR_FILE}" | awk '{print $1}')"
  printf 'frozen_pack=%s\n' "${FROZEN_PACK_DIR}"
  printf 'execution_pack=%s\n' "${EXECUTION_PACK}"
  printf 'execution_pack_source_link=%s\n' "$(readlink "${EXECUTION_PACK}/source/RoboMemArena_d9f83ac")"
  printf 'frozen_entrypoint=%s\n' "${FROZEN_ENTRYPOINT}"
  printf 'frozen_entrypoint_sha256=%s\n' "$(sha256sum "${FROZEN_ENTRYPOINT}" | awk '{print $1}')"
  printf 'frozen_runner=%s\n' "${FROZEN_RUNNER}"
  printf 'frozen_runner_sha256=%s\n' "$(sha256sum "${FROZEN_RUNNER}" | awk '{print $1}')"
  printf 'frozen_evaluator=%s\n' "${FROZEN_EVALUATOR}"
  printf 'frozen_evaluator_sha256=%s\n' "$(sha256sum "${FROZEN_EVALUATOR}" | awk '{print $1}')"
  printf 'vla_ckpt=%s\n' "${VLA_CKPT}"
  printf 'vla_norm=%s\n' "${VLA_NORM}"
  printf 'vla_norm_sha256=%s\n' "$(sha256sum "${VLA_NORM}" | awk '{print $1}')"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'seed=%s\n' "${SEED}"
  printf 'campaign_git_commit=%s\n' "${CAMPAIGN_GIT_COMMIT}"
  printf 'single_gpu_overlay=disabled\n'
  printf 'oracle_prompt_injection=off\n'
} > "${OUT_ROOT}/historical_runtime_manifest.env"

# Do not pass campaign remapping variables into the frozen runner. It must see
# Slurm's two-device allocation and preserve its VLA=0 / evaluator=1 split.
unset VLA_CUDA_VISIBLE_DEVICES VLM_CUDA_VISIBLE_DEVICES MUJOCO_EGL_DEVICE_ID

if [[ "${TASK_ID}" == "6" ]]; then
  REPEAT_START=${REPEAT_START:-0}
  REPEAT_COUNT=${REPEAT_COUNT:-20}
  [[ "${REPEAT_START}" == "0" && "${REPEAT_COUNT}" == "20" ]] || {
    echo "Task6 historical direct comparator requires repeats 0..19 in one job" >&2
    exit 2
  }
  RUNNER="${EXECUTION_RUNNER}" \
  RUN_GROUP="${RUN_ID}" \
  WORKER_ID=0 \
  REPEAT_START="${REPEAT_START}" \
  REPEAT_COUNT="${REPEAT_COUNT}" \
  FIXED_SEED="${SEED}" \
  RUNS_BASE="${OUT_ROOT}/workers/worker0" \
  LOG_DIR="${OUT_ROOT}/logs" \
  BASE_PORT="${PORT}" \
  RUNTIME_HOME="${RUNTIME_HOME:-${HOME}}" \
  SOURCE_ROOT="${SOURCE_ROOT}" \
  OPENPI_ROOT="${OPENPI_ROOT}" \
  OPENPI_INFERENCE_ROOT="${OPENPI_INFERENCE_ROOT}" \
  TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
  VLA_CKPT="${VLA_CKPT}" \
  VLM_CKPT="${VLM_CKPT}" \
  bash "${EXECUTION_ENTRYPOINT}"

  python3 "${EXECUTION_PACK}/scripts/summarize_task6_fixed_seed_repeat_group.py" \
    --workers-root "${OUT_ROOT}/workers" \
    --expected-episodes=20 \
    --expected-seed="${SEED}" \
    --out-dir "${OUT_ROOT}/aggregate"
  exit 0
fi

NUM_TRIALS=${NUM_TRIALS:-20}
[[ "${NUM_TRIALS}" == "20" ]] || {
  echo "Task16 historical direct comparator requires NUM_TRIALS=20" >&2
  exit 2
}

SOURCE_ROOT="${SOURCE_ROOT}" \
OPENPI_ROOT="${OPENPI_ROOT}" \
OPENPI_INFERENCE_ROOT="${OPENPI_INFERENCE_ROOT}" \
TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
VLA_CKPT="${VLA_CKPT}" \
VLM_CKPT="${VLM_CKPT}" \
NUM_TRIALS="${NUM_TRIALS}" \
SEED="${SEED}" \
PORT="${PORT}" \
RUN_ID="${RUN_ID}" \
OUT_ROOT="${OUT_ROOT}" \
RUNTIME_HOME="${RUNTIME_HOME:-${HOME}}" \
bash "${EXECUTION_ENTRYPOINT}"
