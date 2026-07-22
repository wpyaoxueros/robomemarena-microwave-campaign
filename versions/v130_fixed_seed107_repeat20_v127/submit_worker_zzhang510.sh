#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${BATCH_ROOT:?set BATCH_ROOT}"
: "${WORKER_ID:?set WORKER_ID}"
: "${BASE_PORT:?set BASE_PORT}"
REQUESTED_FIXED_SEED="${FIXED_SEED:-107}"
REPEATS="${REPEATS:-4}"
[[ "${REQUESTED_FIXED_SEED}" == "107" ]] || { echo "v130 is fixed to seed107" >&2; exit 2; }
FIXED_SEED=107
[[ "${WORKER_ID}" =~ ^[0-4]$ ]] || { echo "WORKER_ID must be 0..4" >&2; exit 2; }
[[ "${REPEATS}" == "4" ]] || { echo "v130 requires four attempts per worker" >&2; exit 2; }
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are unreadable" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
PARTITION="${PARTITION:-acd_u}"
CPUS_PER_TASK=8
MAX_MEM_PER_CPU_MB="$(scontrol show partition "${PARTITION}" | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p' | head -1)"
MEM_MB="${MEM_MB:-$((CPUS_PER_TASK * ${MAX_MEM_PER_CPU_MB:-20480}))}"
WORKER_ROOT="${BATCH_ROOT}/worker${WORKER_ID}"
SESSION="${SESSION:-task21_v130_${STAMP}_w${WORKER_ID}}"
JOB_NAME="${JOB_NAME:-task21v130_${STAMP}_w${WORKER_ID}}"

mkdir -p "${WORKER_ROOT}"
umask 077
RUNTIME_ENV="${WORKER_ROOT}/v130_worker_runtime.env"
{
  printf 'export PRIVATE_INPUTS_FILE=%q\n' "${PRIVATE_INPUTS_FILE}"
  printf 'export BATCH_ROOT=%q\n' "${BATCH_ROOT}"
  printf 'export WORKER_ID=%q\n' "${WORKER_ID}"
  printf 'export BASE_PORT=%q\n' "${BASE_PORT}"
  printf 'export FIXED_SEED=%q\n' "${FIXED_SEED}"
  printf 'export REPEATS=%q\n' "${REPEATS}"
} >"${RUNTIME_ENV}"
chmod 600 "${RUNTIME_ENV}"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/run_worker.sh" \
  "${VERSION_DIR}/validate_episode.py" "${VERSION_DIR}/submit_worker_zzhang510.sh" \
  "${VERSION_DIR}/aggregate_fixedseed20.py" "${WORKER_ROOT}/"

RUNNER_Q="$(printf '%q' "${VERSION_DIR}/run_worker.sh")"
ENV_Q="$(printf '%q' "${RUNTIME_ENV}")"
LOG_Q="$(printf '%q' "${WORKER_ROOT}/submit.log")"
INNER="set -o pipefail; srun -p ${PARTITION} --nodes=1 --gres=gpu:2 -c${CPUS_PER_TASK} --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} bash ${RUNNER_Q} ${ENV_Q} 2>&1 | tee -a ${LOG_Q}; rc=\${PIPESTATUS[0]}; echo \"[TMUX_EXIT] status=\${rc}\"; exit \${rc}"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc $(printf '%q' "${INNER}")"

printf 'session=%s\njob_name=%s\nworker_id=%s\nfixed_seed=%s\nrepeats=%s\npartition=%s\nout_root=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${WORKER_ID}" "${FIXED_SEED}" "${REPEATS}" "${PARTITION}" "${WORKER_ROOT}"
