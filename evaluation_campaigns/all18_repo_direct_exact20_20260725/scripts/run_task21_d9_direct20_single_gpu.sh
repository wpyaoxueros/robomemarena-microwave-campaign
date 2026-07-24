#!/usr/bin/env bash
set -euo pipefail

# Run the frozen Task21 v130 5x4 protocol on one Slurm-visible GPU. The
# package itself is copied to a job-local overlay so its historical source
# remains byte-for-byte unchanged while the scorer is pinned to d9.

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to the submit-account output root}

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose a GPU" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 1 ]] || {
  echo "Task21 direct runner requires one visible GPU, got ${CUDA_VISIBLE_DEVICES}" >&2
  exit 2
}

SOURCE_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
EXPECTED_SCORER_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538
SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725
TARGET_LIBERO_PATH=/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork
OPENPI_ROOT=/data/user/hlei573/openpi
INFER_ROOT=/data/user/hlei573/openpi_inference
VLA_POLICY=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLA_REPO_ID="${VLA_POLICY}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2"
VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260701_082527_task21r17c_task21_r17_openkeep_latepick_rawtrace_open_microwave_to_pick_butter/hzhang061/eval_artifacts/vlm_eval_ready/task21_task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000_20260701_100519/task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000
TASK21_DATA_ROOT=/data/user/hlei573/data/full_trajectory_v2/21_butter_chocolate_microwave_dataset
TASK21_PACK="${REPO_DIR}/tasks/task21"
SCORER_FILE="${SOURCE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py"

for required in \
  "${TASK21_PACK}" "${SOURCE_ROOT}" "${SCORER_FILE}" "${TARGET_LIBERO_PATH}" \
  "${OPENPI_ROOT}" "${INFER_ROOT}" "${VLA_POLICY}" "${VLA_REPO_ID}/norm_stats.json" \
  "${VLM_CKPT}/model.safetensors" "${TASK21_DATA_ROOT}"; do
  [[ -e "${required}" ]] || { echo "missing recorded asset: ${required}" >&2; exit 3; }
done

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

STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}
RUN_ID=${RUN_ID:-task21_all18_d9_direct20_single_gpu_${STAMP}}
OUT_ROOT="${OUTPUT_ROOT}/task21/${RUN_ID}"
OVERLAY_ROOT="${OUT_ROOT}/d9_overlay"
BATCH_ROOT="${OUT_ROOT}/batch"
PRIVATE_INPUTS_FILE="${OUT_ROOT}/private_inputs.env"
OVERLAY_BUILDER="${CAMPAIGN_DIR}/scripts/materialize_microwave_d9_overlay.py"

mkdir -p "${OUT_ROOT}/code_snapshot"
python3 "${OVERLAY_BUILDER}" \
  --source-pack "${TASK21_PACK}" \
  --source-root "${SOURCE_ROOT}" \
  --source-commit "${SOURCE_COMMIT}" \
  --output "${OVERLAY_ROOT}" | tee "${OUT_ROOT}/overlay_build.log"

cat >"${PRIVATE_INPUTS_FILE}" <<EOF
export OPENPI_ROOT=${OPENPI_ROOT}
export INFER_ROOT=${INFER_ROOT}
export TARGET_LIBERO_PATH=${TARGET_LIBERO_PATH}
export ROBOMEMARENA_REMOTE_ROOT=${SOURCE_ROOT}
export TASK21_DATA_ROOT=${TASK21_DATA_ROOT}
export VLA_POLICY=${VLA_POLICY}
export VLA_REPO_ID=${VLA_REPO_ID}
export VLA_CONFIG=pi05_libero_robomemarena_fullvlm_v2_noflip_dataset
export VLM_CKPT=${VLM_CKPT}
EOF
chmod 600 "${PRIVATE_INPUTS_FILE}"

cp -p "${BASH_SOURCE[0]}" "${OVERLAY_BUILDER}" "${OUT_ROOT}/code_snapshot/"
{
  printf 'task_id=21\n'
  printf 'run_id=%s\n' "${RUN_ID}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID}"
  printf 'remote_commit=%s\n' "${actual_commit}"
  printf 'remote_scorer_sha256=%s\n' "${actual_scorer_sha}"
  printf 'frozen_package=%s\n' "${TASK21_PACK}"
  printf 'overlay_root=%s\n' "${OVERLAY_ROOT}"
  printf 'overlay_manifest_sha256=%s\n' "$(sha256sum "${OVERLAY_ROOT}/overlay_manifest.json" | awk '{print $1}')"
  printf 'vla_ckpt=%s\n' "${VLA_POLICY}"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'norm=%s\n' "${VLA_REPO_ID}/norm_stats.json"
  printf 'task_data_root=%s\n' "${TASK21_DATA_ROOT}"
  printf 'cuda_visible_devices_before_remap=%s\n' "${CUDA_VISIBLE_DEVICES}"
  printf 'vla_cuda_visible_devices=0\n'
  printf 'vlm_cuda_visible_devices=0\n'
  printf 'mujoco_egl_device_id=0\n'
  printf 'campaign_git_commit=%s\n' "$(git -C "${REPO_DIR}" rev-parse HEAD)"
} >"${OUT_ROOT}/campaign_manifest.env"

export CUDA_VISIBLE_DEVICES=0
export VLA_CUDA_VISIBLE_DEVICES=0
export VLM_CUDA_VISIBLE_DEVICES=0
export MUJOCO_EGL_DEVICE_ID=0
export RUNTIME_HOME="${RUNTIME_HOME:-${HOME}}"

WORKER="${OVERLAY_ROOT}/versions/v130_fixed_seed107_repeat20_v127/run_worker.sh"
AGGREGATOR="${OVERLAY_ROOT}/versions/v130_fixed_seed107_repeat20_v127/aggregate_fixedseed20.py"
for worker_id in 0 1 2 3 4; do
  PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
  BATCH_ROOT="${BATCH_ROOT}" \
  WORKER_ID="${worker_id}" \
  BASE_PORT="$((9821 + worker_id * 10))" \
  FIXED_SEED=107 \
  REPEATS=4 \
  bash "${WORKER}" "${PRIVATE_INPUTS_FILE}"
done

python3 "${AGGREGATOR}" \
  --batch-root "${BATCH_ROOT}" \
  --output-dir "${OUT_ROOT}/aggregate" | tee "${OUT_ROOT}/aggregate.log"
