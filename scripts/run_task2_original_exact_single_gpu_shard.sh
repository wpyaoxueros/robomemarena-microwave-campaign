#!/usr/bin/env bash
set -euo pipefail

: "${RUN_ID:?set RUN_ID}"
: "${START_SEED:?set START_SEED}"
: "${EPISODE_COUNT:?set EPISODE_COUNT}"
: "${PORT:?set PORT}"

[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside Slurm" >&2; exit 2; }
[[ "${EPISODE_COUNT}" =~ ^[12]$ ]] || { echo "EPISODE_COUNT must be 1 or 2" >&2; exit 2; }
[[ "${START_SEED}" =~ ^[0-9]+$ ]] || { echo "START_SEED must be an integer" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES:-}"
[[ ${#visible_gpus[@]} -eq 1 ]] || {
  echo "Task2 shard requires exactly one Slurm-visible GPU, got ${CUDA_VISIBLE_DEVICES:-unset}" >&2
  exit 2
}

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_TOOL="${REPO_DIR}/scripts/central_evidence.py"
EVIDENCE_ROOT="${REPO_DIR}/evidence"
PACK_ROOT=/data/user/hlei573/vla_memory_experiments/repro_eval_packs/task123_exact/task23_vla35998
# Task2 must use one current official source for both the rollout BDDL and the
# stage scorer.  The old May checkout has a file named butter/popcorn whose
# contents describe cream/pudding, so it is not a valid Task2 contract.
REMOTE_ROOT=/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725
EXPECTED_REMOTE_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
EXPECTED_TASK2_BDDL_SHA256=df9035b23260d3f664f0852e155e2bc3e469897f7999792c365c949a9df244b7
EXPECTED_TASK2_STAGE_SHA256=0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538
TARGET_LIBERO_PATH=/data/user/hlei573/RoboMemArena_github/LIBERO/libero
VLA_POLICY=/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999
VLA_REPO_ID="${VLA_POLICY}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2"
VLA_NORM="${VLA_REPO_ID}/norm_stats.json"
VLM_CKPT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task2_r1_exact20_eval_20260701_135219/vlm_eval_ready/task2_r1_ckpt500_20260701_143058
# Version-controlled copy of the compatibility adapter.  Do not point formal
# Task2 reruns at a mutable external repro pack.
EVAL_PY="${REPO_DIR}/adapters/task2_d9latest_officialscore.py"
RUNNER_PY="${PACK_ROOT}/evaluators/run_tasks2_26_sync_hold_eval.sh"
ENTRYPOINT="${PACK_ROOT}/run_one_task123.sh"
SCORER_FILE="${REMOTE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py"
TASK2_BDDL="${REMOTE_ROOT}/evaluation_benchmark/bddl/2_butter_popcorn_basket.bddl"
TASK_CONFIG="${REMOTE_ROOT}/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json"
TARGETS="${PACK_ROOT}/config/tasks2_26_endpose_targets_seed100_199.json"

for required in \
  "${EVIDENCE_TOOL}" "${PACK_ROOT}" "${REMOTE_ROOT}" "${TARGET_LIBERO_PATH}" \
  "${VLA_POLICY}" "${VLA_NORM}" "${VLM_CKPT}" "${EVAL_PY}" "${RUNNER_PY}" \
  "${ENTRYPOINT}" "${SCORER_FILE}" "${TASK2_BDDL}" "${TASK_CONFIG}" "${TARGETS}"; do
  [[ -r "${required}" ]] || { echo "unreadable required asset: ${required}" >&2; exit 3; }
done

SCORER_COMMIT="$(git -C "${REMOTE_ROOT}" rev-parse HEAD 2>/dev/null || echo unknown)"
[[ "${SCORER_COMMIT}" == "${EXPECTED_REMOTE_COMMIT}" ]] || {
  echo "unexpected official remote commit: ${SCORER_COMMIT}" >&2
  exit 3
}
[[ "$(sha256sum "${TASK2_BDDL}" | awk '{print $1}')" == "${EXPECTED_TASK2_BDDL_SHA256}" ]] || {
  echo "Task2 BDDL checksum mismatch: ${TASK2_BDDL}" >&2
  exit 3
}
[[ "$(sha256sum "${SCORER_FILE}" | awk '{print $1}')" == "${EXPECTED_TASK2_STAGE_SHA256}" ]] || {
  echo "Task2 stage scorer checksum mismatch: ${SCORER_FILE}" >&2
  exit 3
}
mkdir -p "${EVIDENCE_ROOT}/submission_manifests"
MANIFEST_SOURCE="${EVIDENCE_ROOT}/submission_manifests/${RUN_ID}.json"
cat >"${MANIFEST_SOURCE}" <<EOF
{
  "run_id": "${RUN_ID}",
  "campaign_id": "task2_original_exact_parallel20_20260725",
  "task_id": 2,
  "submit_user": "$(id -un)",
  "seed_spec": "${START_SEED}-$((START_SEED + EPISODE_COUNT - 1))",
  "policy_seed": 104,
  "episode_target": ${EPISODE_COUNT},
  "post_goal_steps": 0,
  "topology": "single_gpu_colocated_vla_vlm",
  "scoring_contract": "d9f83ac_task2_butter_popcorn_bddl_and_reference_stage",
  "oracle_prompt_injection": false,
  "object_anchor": false,
  "fallback_used": false,
  "vla_checkpoint": "${VLA_POLICY}",
  "vla_norm": "${VLA_NORM}",
  "vlm_checkpoint": "${VLM_CKPT}",
  "evaluator_path": "${EVAL_PY}",
  "scorer_path": "${SCORER_FILE}",
  "scorer_commit": "${SCORER_COMMIT}",
  "evaluator_commit": "task2_original_exact_pack_adapter",
  "launch_command": "${BASH_SOURCE[0]} RUN_ID=${RUN_ID} START_SEED=${START_SEED} EPISODE_COUNT=${EPISODE_COUNT}",
  "entrypoint": "${BASH_SOURCE[0]}"
}
EOF

python3 "${EVIDENCE_TOOL}" init --manifest "${MANIFEST_SOURCE}"
RUN_DIR="${EVIDENCE_ROOT}/runs/${RUN_ID}"
python3 "${EVIDENCE_TOOL}" transition --run-id "${RUN_ID}" --status submitted
python3 "${EVIDENCE_TOOL}" transition --run-id "${RUN_ID}" --status running
cp -p "${ENTRYPOINT}" "${EVAL_PY}" "${RUNNER_PY}" "${RUN_DIR}/code_snapshot/"
cp -p "${TARGETS}" "${RUN_DIR}/code_snapshot/"
cp -p "${TASK2_BDDL}" "${SCORER_FILE}" "${RUN_DIR}/code_snapshot/"
printf 'slurm_job_id=%s\nvisible_gpu=%s\nhostname=%s\n' \
  "${SLURM_JOB_ID}" "${CUDA_VISIBLE_DEVICES}" "$(hostname)" >"${RUN_DIR}/artifacts/allocation.env"

set +e
CUDA_VISIBLE_DEVICES=0 \
VLA_CUDA_VISIBLE_DEVICES=0 \
VLM_CUDA_VISIBLE_DEVICES=0 \
OPENPI_ROOT=/data/user/hlei573/openpi \
INFER_ROOT=/data/user/hlei573/openpi_inference \
TARGET_LIBERO_PATH="${TARGET_LIBERO_PATH}" \
ROBOMEMARENA_REMOTE_ROOT="${REMOTE_ROOT}" \
OUTPUT_ROOT="${RUN_DIR}/artifacts" \
RUN_ID="${RUN_ID}" \
PORT="${PORT}" \
VLA_POLICY="${VLA_POLICY}" \
VLA_REPO_ID="${VLA_REPO_ID}" \
VLA_SERVER_PY="${PACK_ROOT}/scripts/serve_policy_custom_repo.py" \
TASK2_VLM_CKPT="${VLM_CKPT}" \
TASKS2_26_LATEST_REMOTE_INTERFACE=1 \
NUM_TRIALS="${EPISODE_COUNT}" \
SEED="${START_SEED}" \
MAX_STEPS=2000 \
REPLAN_STEPS=5 \
POST_HOLD_RELEASE_VLA_STEPS=30 \
bash "${ENTRYPOINT}" 2 >"${RUN_DIR}/logs/launch.log" 2>&1
RC=$?
set -e

RUN_ROOT="${RUN_DIR}/artifacts/task2/logs_task_sync_hold/${RUN_ID}"
EPISODES="${RUN_ROOT}/official_episodes.tsv"
episodes_completed=0
stage_successes=0
goal_successes=0
if [[ -f "${EPISODES}" ]]; then
  episodes_completed=$(( $(wc -l <"${EPISODES}") - 1 ))
  stage_successes=$(awk -F '\t' 'NR > 1 && $6 == "Y" {count++} END {print count+0}' "${EPISODES}")
  goal_successes=$(awk -F '\t' 'NR > 1 && $7 == "Y" {count++} END {print count+0}' "${EPISODES}")
fi

if [[ "${RC}" -eq 0 && "${episodes_completed}" -eq "${EPISODE_COUNT}" ]]; then
  python3 "${EVIDENCE_TOOL}" transition --run-id "${RUN_ID}" --status completed \
    --episodes-completed "${episodes_completed}" \
    --stage-successes "${stage_successes}" \
    --goal-successes "${goal_successes}"
else
  python3 "${EVIDENCE_TOOL}" transition --run-id "${RUN_ID}" --status failed \
    --episodes-completed "${episodes_completed}" \
    --stage-successes "${stage_successes}" \
    --goal-successes "${goal_successes}"
fi
exit "${RC}"
