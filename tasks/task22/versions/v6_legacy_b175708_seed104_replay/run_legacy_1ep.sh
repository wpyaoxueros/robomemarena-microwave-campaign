#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:-${PRIVATE_INPUTS_FILE:-}}"
[[ -n "${PRIVATE_INPUTS_FILE}" && -r "${PRIVATE_INPUTS_FILE}" ]] || {
  echo "usage: $0 /absolute/path/to/inputs.env" >&2
  exit 2
}
# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"

for required in OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH VLM_CKPT VLA_POLICY VLA_CONFIG VLA_REPO_ID; do
  [[ -n "${!required:-}" ]] || { echo "missing ${required}" >&2; exit 2; }
done
for readable in "${OPENPI_ROOT}" "${INFER_ROOT}" "${TARGET_LIBERO_PATH}" "${VLM_CKPT}" "${VLA_POLICY}" "${VLA_REPO_ID}"; do
  [[ -r "${readable}" ]] || { echo "unreadable input: ${readable}" >&2; exit 2; }
done

bash "${VERSION_DIR}/verify_snapshot.sh"

export TASKS_JSON='[22]'
export NUM_TRIALS=1
export SEED=104
export MAX_STEPS=2000
export REPLAN_STEPS=10
export NUM_STEPS_WAIT=10
export ASYNC_VLM=1
export VLM_INTERVAL=5
export VLM_QUEUE_SIZE=1
export N_RECENT=5
export K_MAX=0
export VLM_USE_WRIST=1
export VLM_USE_KEYFRAME_MEMORY=1
export VLM_INPUT_PROFILE=fullvlm_256
export VLM_MATCH_TRAINING_JPEG_ROUNDTRIP=0
export VLM_LONGTASK_PROMPT=0
export VLM_DEVICE=cuda:0
export VLM_LORA_PATH=none
export D_MERGE=6
export PYOPENGL_PLATFORM=egl
export MUJOCO_GL=egl
export PYTHONUNBUFFERED=1
export PYTHONNOUSERSITE=1
export OPENPI_INFERENCE_ROOT="${INFER_ROOT}"

export LEGACY_SERVER_CUDA_VISIBLE_DEVICES="${LEGACY_SERVER_CUDA_VISIBLE_DEVICES:-0}"
export LEGACY_EVAL_CUDA_VISIBLE_DEVICES="${LEGACY_EVAL_CUDA_VISIBLE_DEVICES:-1}"
export PORT="${PORT:-8722}"
export RUN_ID="${RUN_ID:-task22_v6_legacy_b175708_seed104_$(date +%Y%m%d_%H%M%S)}"
export OUTPUT_ROOT="${OUTPUT_ROOT:-${VERSION_DIR}/outputs}"
export OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
export VIDEO_DIR="${OUT_ROOT}/videos"
export SUMMARY_TSV="${OUT_ROOT}/summary.tsv"
export SUMMARY_JSON="${OUT_ROOT}/summary.json"
export PROMPT_TRACE_TSV="${OUT_ROOT}/prompt_trace.tsv"
export LOG_DIR="${OUT_ROOT}/logs"
export SERVER_LOG="${LOG_DIR}/serve_policy_legacy.log"
export EVAL_LOG="${LOG_DIR}/eval_legacy.log"

OFFICIAL_DIR="${VERSION_DIR}/runtime/evaluation_benchmark/async_vlm26_reference"
RUNTIME_DIR="${VERSION_DIR}/runtime/evaluation_benchmark/openpi_minimal_runtime"
SERVER_PY="${VERSION_DIR}/runtime/serve_policy_custom_repo.py"
EVAL_PY="${OFFICIAL_DIR}/eval_fullvlm26_async_vlm_vla.py"
export TASK_CONFIG="${OFFICIAL_DIR}/fullvlm_v2_26_memory_tasks.json"

umask 007
mkdir -p "${LOG_DIR}" "${VIDEO_DIR}"
printf '%s\n' \
  'legacy_commit=b175708317abacfbce86c4911cc492d68a3ea163' \
  'task=22' \
  'seed=104' \
  'num_trials=1' \
  'max_steps=2000' \
  'replan_steps=10' \
  'async_vlm=1' \
  'oracle_prompt_injection=absent_from_legacy_evaluator' \
  > "${OUT_ROOT}/reproduction_contract.tsv"

export PYTHONPATH="${TARGET_LIBERO_PATH}:${RUNTIME_DIR}:${OPENPI_ROOT}/packages/openpi-client/src:${OPENPI_ROOT}/packages/openpi/src:${OPENPI_ROOT}:${PYTHONPATH:-}"
export HOST=127.0.0.1

SERVER_PID=''
cleanup() {
  if [[ -n "${SERVER_PID}" ]] && kill -0 "${SERVER_PID}" 2>/dev/null; then
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

python3 - <<PY
import socket
s = socket.socket()
s.settimeout(0.2)
try:
    s.connect(("127.0.0.1", int("${PORT}")))
except OSError:
    raise SystemExit(0)
raise SystemExit("port ${PORT} is already in use")
PY

CUDA_VISIBLE_DEVICES="${LEGACY_SERVER_CUDA_VISIBLE_DEVICES}" "${OPENPI_ROOT}/.venv/bin/python3" "${SERVER_PY}" \
  --config "${VLA_CONFIG}" \
  --dir "${VLA_POLICY}" \
  --repo-id "${VLA_REPO_ID}" \
  --port "${PORT}" \
  > "${SERVER_LOG}" 2>&1 &
SERVER_PID=$!

for _ in $(seq 1 180); do
  sleep 2
  if python3 - <<PY
import socket
s = socket.socket()
s.settimeout(1.0)
try:
    s.connect(("127.0.0.1", int("${PORT}")))
finally:
    s.close()
PY
  then
    break
  fi
  if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    tail -n 160 "${SERVER_LOG}" >&2 || true
    exit 1
  fi
done

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
  echo "legacy VLA server did not become ready" >&2
  exit 1
fi

set +e
CUDA_VISIBLE_DEVICES="${LEGACY_EVAL_CUDA_VISIBLE_DEVICES}" "${INFER_ROOT}/.venv/bin/python" "${EVAL_PY}" 2>&1 | tee "${EVAL_LOG}"
EVAL_RC=${PIPESTATUS[0]}
set -e
printf 'eval_exit_code=%s\n' "${EVAL_RC}" > "${OUT_ROOT}/exit_status.tsv"
exit "${EVAL_RC}"

