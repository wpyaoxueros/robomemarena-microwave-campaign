#!/usr/bin/env bash
set -euo pipefail

# Drop-in replacement for RoboMemArena's tasks2_26_vlm5_reference runner.
# It deliberately keeps the upstream environment-variable interface.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${OPENPI_ROOT:?Set OPENPI_ROOT to the OpenPI checkout.}"
: "${OPENPI_INFERENCE_ROOT:?Set OPENPI_INFERENCE_ROOT to the openpi_inference checkout.}"
: "${TARGET_LIBERO_PATH:?Set TARGET_LIBERO_PATH to LIBERO/libero.}"
: "${VLM_CKPT:?Set VLM_CKPT to the VLM checkpoint directory.}"
: "${VLA_CKPT:?Set VLA_CKPT to the VLA checkpoint directory.}"

ROBOMEMARENA_OFFICIAL_ROOT=${ROBOMEMARENA_OFFICIAL_ROOT:-$(cd "${SCRIPT_DIR}/../../.." && pwd)}
OFFICIAL_SCRIPTS="${ROBOMEMARENA_OFFICIAL_ROOT}/evaluation_benchmark/scripts"
OFFICIAL_BDDL="${ROBOMEMARENA_OFFICIAL_ROOT}/evaluation_benchmark/bddl"
VLA_CONFIG=${VLA_CONFIG:-pi05_libero_robomemarena_fullvlm_v2_noflip_dataset}
VLA_REPO_ID=${VLA_REPO_ID:-${VLA_CKPT}/assets/robomemarena_fullvlm_v2_noflip_dataset_v2}
OPENPI_PYTHON=${OPENPI_PYTHON:-${OPENPI_ROOT}/.venv/bin/python3}
EVAL_PYTHON=${EVAL_PYTHON:-${OPENPI_INFERENCE_ROOT}/.venv/bin/python}
PORT=${PORT:-8026}
TS=${TS:-$(date +%Y%m%d_%H%M%S)}
OUT_ROOT=${OUT_ROOT:-${OPENPI_INFERENCE_ROOT}/output/eval_tasks2_26_vlm_vla_${TS}}
VIDEO_DIR=${VIDEO_DIR:-${OUT_ROOT}/videos}
SUMMARY_JSON=${SUMMARY_JSON:-${OUT_ROOT}/summary.json}
SUMMARY_TSV=${SUMMARY_TSV:-${OUT_ROOT}/summary.tsv}
PROMPT_TRACE_TSV=${PROMPT_TRACE_TSV:-${OUT_ROOT}/prompt_trace.tsv}
LOG_DIR=${LOG_DIR:-${OUT_ROOT}/logs}
SERVER_LOG=${SERVER_LOG:-${LOG_DIR}/serve_policy.log}
EVAL_LOG=${EVAL_LOG:-${LOG_DIR}/eval_tasks2_26_vlm_vla.log}
TASK_CONFIG=${TASK_CONFIG:-${SCRIPT_DIR}/fullvlm_v2_26_memory_tasks.json}
ENDPOSE_HOLD_TARGETS_JSON=${ENDPOSE_HOLD_TARGETS_JSON:-${SCRIPT_DIR}/tasks2_26_endpose_targets_seed100_199.json}
TASKS_JSON=${TASKS_JSON:-"[20,21,22,23,24]"}
NUM_TRIALS=${NUM_TRIALS:-1}
SEED=${SEED:-100}
REPLAN_STEPS=${REPLAN_STEPS:-10}
MAX_STEPS=${MAX_STEPS:-2500}
POST_GOAL_STEPS=${POST_GOAL_STEPS:-200}
SERVER_CUDA_VISIBLE_DEVICES=${SERVER_CUDA_VISIBLE_DEVICES:-0}
EVAL_CUDA_VISIBLE_DEVICES=${EVAL_CUDA_VISIBLE_DEVICES:-1}

for required in \
  "${OPENPI_PYTHON}" "${EVAL_PYTHON}" "${VLM_CKPT}" "${VLA_CKPT}" \
  "${VLA_REPO_ID}/norm_stats.json" "${TARGET_LIBERO_PATH}" "${TASK_CONFIG}" \
  "${ENDPOSE_HOLD_TARGETS_JSON}" "${OFFICIAL_SCRIPTS}/task2_26_reference_stage.py" \
  "${OFFICIAL_BDDL}/2_butter_popcorn_basket.bddl"; do
  [[ -r "${required}" ]] || { echo "[ERROR] unreadable required path: ${required}" >&2; exit 2; }
done

mkdir -p "${LOG_DIR}" "${VIDEO_DIR}"
export PYOPENGL_PLATFORM=${PYOPENGL_PLATFORM:-egl}
export MUJOCO_GL=${MUJOCO_GL:-egl}
export PYTHONUNBUFFERED=1
export OPENPI_ROOT OPENPI_INFERENCE_ROOT TARGET_LIBERO_PATH
export OUT_ROOT VIDEO_DIR SUMMARY_JSON SUMMARY_TSV PROMPT_TRACE_TSV TASK_CONFIG
export HOST=${HOST:-127.0.0.1} PORT VLM_CKPT VLA_REPO_ID TASKS_JSON NUM_TRIALS SEED REPLAN_STEPS MAX_STEPS POST_GOAL_STEPS
export ENDPOSE_HOLD_TARGETS_JSON
export ROBOMEMARENA_REMOTE_ROOT="${ROBOMEMARENA_OFFICIAL_ROOT}"
export ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${OFFICIAL_SCRIPTS}"
export ROBOMEMARENA_OFFICIAL_BDDL_DIR="${OFFICIAL_BDDL}"
export TASKS2_26_BASE_EVAL_PY="${SCRIPT_DIR}/eval_tasks2_26_vlm_vla_base.py"
export TASKS2_26_LATEST_REMOTE_INTERFACE=1
export ASYNC_VLM=${ASYNC_VLM:-0}
export VLM_DEVICE=${VLM_DEVICE:-cuda:0}
export N_RECENT=${N_RECENT:-5}
export K_MAX=${K_MAX:-0}
export D_MERGE=${D_MERGE:-6}
export VLM_USE_WRIST=${VLM_USE_WRIST:-1}
export VLM_USE_KEYFRAME_MEMORY=${VLM_USE_KEYFRAME_MEMORY:-1}
export VLM_INPUT_PROFILE=${VLM_INPUT_PROFILE:-fullvlm_256}
export NUM_STEPS_WAIT=${NUM_STEPS_WAIT:-10}
export ENABLE_ENDPOSE_HOLD=${ENABLE_ENDPOSE_HOLD:-1}
export DISABLE_OUTPUT_NORMALIZE=${DISABLE_OUTPUT_NORMALIZE:-1}
export VLM_TASK_TEXT_MODE=${VLM_TASK_TEXT_MODE:-english_reference_no_candidate}

{
  echo "official_root=${ROBOMEMARENA_OFFICIAL_ROOT}"
  echo "official_commit=$(git -C "${ROBOMEMARENA_OFFICIAL_ROOT}" rev-parse HEAD 2>/dev/null || echo unknown)"
  echo "task2_bddl_sha256=$(sha256sum "${OFFICIAL_BDDL}/2_butter_popcorn_basket.bddl" | awk '{print $1}')"
  echo "task2_stage_sha256=$(sha256sum "${OFFICIAL_SCRIPTS}/task2_26_reference_stage.py" | awk '{print $1}')"
  echo "vla_ckpt=${VLA_CKPT}"
  echo "vla_repo_id=${VLA_REPO_ID}"
  echo "vlm_ckpt=${VLM_CKPT}"
  echo "tasks_json=${TASKS_JSON}"
  echo "num_trials=${NUM_TRIALS}"
  echo "seed=${SEED}"
  echo "replan_steps=${REPLAN_STEPS}"
  echo "post_goal_steps=${POST_GOAL_STEPS}"
} >"${OUT_ROOT}/runtime_contract.env"

CUDA_VISIBLE_DEVICES="${SERVER_CUDA_VISIBLE_DEVICES}" "${OPENPI_PYTHON}" "${SCRIPT_DIR}/serve_policy_custom_repo.py" \
  --port "${PORT}" --config "${VLA_CONFIG}" --dir "${VLA_CKPT}" --repo-id "${VLA_REPO_ID}" >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!
cleanup() { kill "${SERVER_PID}" >/dev/null 2>&1 || true; }
trap cleanup EXIT

for _ in $(seq 1 180); do
  if "${EVAL_PYTHON}" - <<PY >/dev/null 2>&1
import socket
s = socket.socket(); s.settimeout(1.0)
try:
    s.connect(("127.0.0.1", int("${PORT}")))
finally:
    s.close()
PY
  then break; fi
  kill -0 "${SERVER_PID}" 2>/dev/null || { tail -n 100 "${SERVER_LOG}"; exit 3; }
  sleep 2
done
kill -0 "${SERVER_PID}" 2>/dev/null || { tail -n 100 "${SERVER_LOG}"; exit 3; }

CUDA_VISIBLE_DEVICES="${EVAL_CUDA_VISIBLE_DEVICES}" "${EVAL_PYTHON}" "${SCRIPT_DIR}/eval_tasks2_26_vlm_vla.py" 2>&1 | tee "${EVAL_LOG}"
