#!/usr/bin/env bash
set -euo pipefail

# Strict Task7 reference comparator. This deliberately delegates to the frozen
# successful 8-episode launcher without changing its two-GPU VLA/VLM/MuJoCo
# topology or its evaluator code.

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose GPUs" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 2 ]] || {
  echo "Task7 historical comparator requires exactly two visible GPUs, got ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

SOURCE_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
EXPECTED_SCORER_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538
SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725
TARGET_LIBERO_PATH=/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork
OPENPI_ROOT=/data/user/hlei573/openpi
OPENPI_INFERENCE_ROOT=/data/user/hlei573/openpi_inference
VLA_CKPT=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLM_CKPT=/data/user/zzhang510/hlei573_borrow_outputs/counting_task7_evalpour1hardcase256aligned_vlm_2gpu_acdu_20260724_093053/vlm_eval_ready/checkpoint-500
FROZEN_PACK_DIR="${REPO_DIR}/counting/task7_vlm35999_latest_d9f83ac_hardcase500_20260724"
FROZEN_RUNNER="${FROZEN_PACK_DIR}/run_task7_8ep.sh"
SCORER_FILE="${SOURCE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py"

for required in \
  "${FROZEN_RUNNER}" "${SOURCE_ROOT}" "${SCORER_FILE}" \
  "${TARGET_LIBERO_PATH}" "${OPENPI_ROOT}" "${OPENPI_INFERENCE_ROOT}" "${VLA_CKPT}" \
  "${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json" \
  "${VLM_CKPT}/model.safetensors"; do
  [[ -e "${required}" ]] || { echo "missing recorded asset: ${required}" >&2; exit 3; }
done

# Borrowed submit accounts may read these frozen repositories without owning
# them. Keep the exception process-local so the account's Git configuration is
# not mutated and the actual rollout remains untouched.
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0=safe.directory
export GIT_CONFIG_VALUE_0="${SOURCE_ROOT}"
export GIT_CONFIG_KEY_1=safe.directory
export GIT_CONFIG_VALUE_1="${REPO_DIR}"

actual_commit="$(git -C "${SOURCE_ROOT}" rev-parse HEAD)"
[[ "${actual_commit}" == "${SOURCE_COMMIT}" ]] || {
  echo "official source mismatch: expected=${SOURCE_COMMIT} actual=${actual_commit}" >&2
  exit 3
}
actual_scorer_sha="$(sha256sum "${SCORER_FILE}" | awk '{print $1}')"
[[ "${actual_scorer_sha}" == "${EXPECTED_SCORER_SHA}" ]] || {
  echo "scorer mismatch: expected=${EXPECTED_SCORER_SHA} actual=${actual_scorer_sha}" >&2
  exit 3
}

# The frozen launcher owns the behavior: VLA=0, evaluator/VLM=1, MuJoCo EGL=1.
grep -Fq 'export MUJOCO_EGL_DEVICE_ID=1' "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh"
grep -Fq 'CUDA_VISIBLE_DEVICES=0 "${SERVER_PY}"' "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh"
grep -Fq 'CUDA_VISIBLE_DEVICES=1 "${EVAL_PY}"' "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh"

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task7_historical_topology_8ep_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/task7_reference/${RUN_ID}"
EXECUTION_PACK="${OUT_ROOT}/execution_pack"
mkdir -p "${OUT_ROOT}/code_snapshot"

# The d9 runtime checkout deliberately excludes the LIBERO fork. The archived
# d9 source tree is the immutable compatible root used by the counting runner.
# This only supplies the external dependency; the frozen launcher itself is not
# copied or modified.
unset VLA_CUDA_VISIBLE_DEVICES
unset VLM_CUDA_VISIBLE_DEVICES
unset MUJOCO_EGL_DEVICE_ID

VLM_MODEL_SHA256="$(sha256sum "${VLM_CKPT}/model.safetensors" | awk '{print $1}')"
python3 "${CAMPAIGN_DIR}/scripts/materialize_task7_historical_execution_pack.py" \
  --frozen-pack "${FROZEN_PACK_DIR}" \
  --source-root "${SOURCE_ROOT}" \
  --output "${EXECUTION_PACK}" | tee "${OUT_ROOT}/execution_pack_build.txt"
EXECUTION_RUNNER="${EXECUTION_PACK}/run_task7_8ep.sh"
EXECUTION_MANIFEST="${EXECUTION_PACK}/execution_pack_manifest.json"

cp -p "${BASH_SOURCE[0]}" "${FROZEN_RUNNER}" \
  "${CAMPAIGN_DIR}/scripts/materialize_task7_historical_execution_pack.py" \
  "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh" \
  "${OUT_ROOT}/code_snapshot/"
{
  printf 'task_id=7\n'
  printf 'run_id=%s\n' "${RUN_ID}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID}"
  printf 'visible_gpu_topology=%s\n' "${CUDA_VISIBLE_DEVICES}"
  printf 'historical_vla_cuda_visible_devices=0\n'
  printf 'historical_vlm_eval_cuda_visible_devices=1\n'
  printf 'historical_mujoco_egl_device_id=1\n'
  printf 'remote_commit=%s\n' "${actual_commit}"
  printf 'remote_scorer_sha256=%s\n' "${actual_scorer_sha}"
  printf 'frozen_pack=%s\n' "${FROZEN_PACK_DIR}"
  printf 'frozen_runner=%s\n' "${FROZEN_RUNNER}"
  printf 'frozen_runner_sha256=%s\n' "$(sha256sum "${FROZEN_RUNNER}" | awk '{print $1}')"
  printf 'frozen_autonomous_runner_sha256=%s\n' "$(sha256sum "${FROZEN_PACK_DIR}/scripts/run_autonomous_task.sh" | awk '{print $1}')"
  printf 'execution_pack=%s\n' "${EXECUTION_PACK}"
  printf 'execution_pack_manifest=%s\n' "${EXECUTION_MANIFEST}"
  printf 'execution_pack_manifest_sha256=%s\n' "$(sha256sum "${EXECUTION_MANIFEST}" | awk '{print $1}')"
  printf 'execution_runner=%s\n' "${EXECUTION_RUNNER}"
  printf 'execution_runner_sha256=%s\n' "$(sha256sum "${EXECUTION_RUNNER}" | awk '{print $1}')"
  printf 'vla_ckpt=%s\n' "${VLA_CKPT}"
  printf 'vla_norm=%s\n' "${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json"
  printf 'vla_norm_sha256=%s\n' "$(sha256sum "${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json" | awk '{print $1}')"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'vlm_model_sha256=%s\n' "${VLM_MODEL_SHA256}"
  printf 'source_root=%s\n' "${SOURCE_ROOT}"
  printf 'target_libero_path=%s\n' "${TARGET_LIBERO_PATH}"
  printf 'num_trials=8\n'
  printf 'seed=100\n'
  printf 'vla_policy_seed=100\n'
  printf 'replan_steps=5\n'
  printf 'post_stage_steps=30\n'
  printf 'post_goal_steps=200\n'
  printf 'vlm_interval=25\n'
  printf 'hold_after_required_stages=0\n'
  printf 'stage_prompt_override=off\n'
  printf 'oracle_prompt_injection=off\n'
  printf 'campaign_git_commit=%s\n' "$(git -C "${REPO_DIR}" rev-parse HEAD)"
} >"${OUT_ROOT}/reference_manifest.env"

export SOURCE_ROOT TARGET_LIBERO_PATH OPENPI_ROOT OPENPI_INFERENCE_ROOT VLA_CKPT VLM_CKPT
export RUNTIME_HOME="${RUNTIME_HOME:-${HOME}}"
export RUN_ID OUT_ROOT
export NUM_TRIALS=8
export SEED=100
export VLA_POLICY_SEED=100
export REPLAN_STEPS=5
export POST_STAGE_STEPS=30
export VLM_INTERVAL=25
export HOLD_AFTER_REQUIRED_STAGES=0
export PORT=${PORT:-29707}

# The frozen package was originally nested in this Git worktree. The generated
# byte-identical copy lives under the submitter's output root, so preserve the
# same provenance-only Git lookup without changing any rollout source file.
export GIT_DIR="${REPO_DIR}/.git"
export GIT_WORK_TREE="${REPO_DIR}"

exec bash "${EXECUTION_RUNNER}"
