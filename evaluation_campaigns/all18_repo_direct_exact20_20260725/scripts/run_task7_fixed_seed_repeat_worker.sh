#!/usr/bin/env bash
set -euo pipefail

# Repeat one exact Task7 environment/policy seed. Each invocation is one
# episode so the upstream evaluator cannot advance SEED to the next task seed.

umask 0002

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
PACK_DIR="${REPO_DIR}/counting/task7_vlm35999_latest_d9f83ac_hardcase500_20260724"
FROZEN_RUNNER="${PACK_DIR}/scripts/run_autonomous_task.sh"
MATERIALIZE_PACK="${CAMPAIGN_DIR}/scripts/materialize_task7_historical_execution_pack.py"

OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT to an irpn-writable run root}
WORKER_ID=${WORKER_ID:?set WORKER_ID}
REPEAT_COUNT=${REPEAT_COUNT:?set REPEAT_COUNT}
FIXED_SEED=${FIXED_SEED:-100}
PORT_BASE=${PORT_BASE:?set PORT_BASE}

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ "${REPEAT_COUNT}" =~ ^[1-9][0-9]*$ ]] || { echo "REPEAT_COUNT must be positive" >&2; exit 2; }
[[ "${FIXED_SEED}" =~ ^[0-9]+$ ]] || { echo "FIXED_SEED must be numeric" >&2; exit 2; }
[[ -x "${FROZEN_RUNNER}" ]] || { echo "missing frozen runner: ${FROZEN_RUNNER}" >&2; exit 2; }
[[ -f "${MATERIALIZE_PACK}" ]] || { echo "missing pack materializer: ${MATERIALIZE_PACK}" >&2; exit 2; }
[[ -d "${OUTPUT_ROOT}" && -w "${OUTPUT_ROOT}" ]] || { echo "OUTPUT_ROOT is not writable: ${OUTPUT_ROOT}" >&2; exit 2; }

SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725
TARGET_LIBERO_PATH=/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork
OPENPI_ROOT=/data/user/hlei573/openpi
OPENPI_INFERENCE_ROOT=/data/user/hlei573/openpi_inference
VLA_CKPT=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLM_CKPT=/data/user/zzhang510/hlei573_borrow_outputs/counting_task7_evalpour1hardcase256aligned_vlm_2gpu_acdu_20260724_093053/vlm_eval_ready/checkpoint-500
SCORER_FILE="${SOURCE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py"
EXPECTED_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
EXPECTED_SCORER_SHA=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538

[[ "$(git -C "${SOURCE_ROOT}" rev-parse HEAD)" == "${EXPECTED_COMMIT}" ]] || {
  echo "official source commit mismatch" >&2
  exit 3
}
[[ "$(sha256sum "${SCORER_FILE}" | awk '{print $1}')" == "${EXPECTED_SCORER_SHA}" ]] || {
  echo "official scorer SHA mismatch" >&2
  exit 3
}

WORKER_ROOT="${OUTPUT_ROOT}/worker${WORKER_ID}"
mkdir -p "${WORKER_ROOT}"
{
  printf 'worker_id=%s\n' "${WORKER_ID}"
  printf 'submitted_user=%s\n' "$(id -un)"
  printf 'slurm_job_id=%s\n' "${SLURM_JOB_ID}"
  printf 'fixed_environment_seed=%s\n' "${FIXED_SEED}"
  printf 'fixed_vla_policy_seed=%s\n' "${FIXED_SEED}"
  printf 'repeat_count=%s\n' "${REPEAT_COUNT}"
  printf 'frozen_runner=%s\n' "${FROZEN_RUNNER}"
  printf 'frozen_runner_sha256=%s\n' "$(sha256sum "${FROZEN_RUNNER}" | awk '{print $1}')"
  printf 'remote_commit=%s\n' "${EXPECTED_COMMIT}"
  printf 'remote_scorer_sha256=%s\n' "${EXPECTED_SCORER_SHA}"
  printf 'vla_ckpt=%s\n' "${VLA_CKPT}"
  printf 'vla_norm_sha256=%s\n' "$(sha256sum "${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json" | awk '{print $1}')"
  printf 'vlm_ckpt=%s\n' "${VLM_CKPT}"
  printf 'vlm_model_sha256=%s\n' "$(sha256sum "${VLM_CKPT}/model.safetensors" | awk '{print $1}')"
  printf 'cuda_visible_devices=%s\n' "${CUDA_VISIBLE_DEVICES:-unset}"
  printf 'replan_steps=5\n'
  printf 'post_stage_steps=30\n'
  printf 'vlm_interval=25\n'
  printf 'oracle_prompt_injection=off\n'
  printf 'object_anchor=off\n'
} >"${WORKER_ROOT}/worker_manifest.env"

for repeat_index in $(seq 0 "$((REPEAT_COUNT - 1))"); do
  EP_ROOT="${WORKER_ROOT}/repeat$(printf '%02d' "${repeat_index}")"
  PORT="$((PORT_BASE + repeat_index))"
  mkdir -p "${EP_ROOT}"
  printf 'repeat=%s port=%s started_at=%s\n' "${repeat_index}" "${PORT}" "$(date -Is)" \
    | tee "${EP_ROOT}/launch.env"

  # The historical success path used this guarded wrapper: VLM still emits every
  # prompt, while the guard only rejects premature/regressive transitions.
  # Materializing a per-episode execution pack preserves the frozen wrapper and
  # points its scorer import at the declared d9 official source.
  EXECUTION_PACK="${EP_ROOT}/execution_pack"
  python3 "${MATERIALIZE_PACK}" \
    --frozen-pack "${PACK_DIR}" \
    --source-root "${SOURCE_ROOT}" \
    --output "${EXECUTION_PACK}" >"${EP_ROOT}/execution_pack_build.txt"
  EVALUATOR_FILE_OVERRIDE="${EXECUTION_PACK}/evaluators/eval_counting_autonomous_guarded_d9f83ac.py"
  EXECUTION_RUNNER="${EXECUTION_PACK}/scripts/run_autonomous_task.sh"

  SOURCE_ROOT="${SOURCE_ROOT}" \
  TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
  OPENPI_ROOT="${OPENPI_ROOT}" \
  OPENPI_INFERENCE_ROOT="${OPENPI_INFERENCE_ROOT}" \
  VLA_CKPT="${VLA_CKPT}" \
  VLM_CKPT="${VLM_CKPT}" \
  TASK_ID=7 \
  NUM_TRIALS=1 \
  SEED="${FIXED_SEED}" \
  VLA_POLICY_SEED="${FIXED_SEED}" \
  REPLAN_STEPS=5 \
  POST_STAGE_STEPS=30 \
  VLM_INTERVAL=25 \
  HOLD_AFTER_REQUIRED_STAGES=0 \
  EVALUATOR_FILE_OVERRIDE="${EVALUATOR_FILE_OVERRIDE}" \
  PORT="${PORT}" \
  RUN_ID="task7_fixedseed${FIXED_SEED}_worker${WORKER_ID}_repeat${repeat_index}" \
  OUT_ROOT="${EP_ROOT}" \
  RUNTIME_HOME="${RUNTIME_HOME:-${HOME}}" \
  bash "${EXECUTION_RUNNER}" >"${EP_ROOT}/driver.log" 2>&1
done
