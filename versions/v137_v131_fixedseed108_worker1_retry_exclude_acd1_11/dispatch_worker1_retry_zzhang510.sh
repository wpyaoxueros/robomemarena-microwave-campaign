#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
REL_VERSION="${VERSION_DIR#${REPO_DIR}/}"
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are unreadable" >&2; exit 2; }
CALLER_OUTPUT_ROOT="${OUTPUT_ROOT}"

# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
OUTPUT_ROOT="${CALLER_OUTPUT_ROOT}"
: "${ROBOMEMARENA_REMOTE_ROOT:?private inputs must define ROBOMEMARENA_REMOTE_ROOT}"
git config --global --add safe.directory "${REPO_DIR}"
git config --global --add safe.directory "${ROBOMEMARENA_REMOTE_ROOT}"
EXPECTED_OFFICIAL_COMMIT=62214036103ee8d5fef9b475dd8b344b6e2cfc03
[[ "$(git -C "${ROBOMEMARENA_REMOTE_ROOT}" rev-parse HEAD)" == "${EXPECTED_OFFICIAL_COMMIT}" ]] || {
  echo "official scorer mismatch before submission" >&2
  exit 2
}
[[ -r "${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py" ]] || {
  echo "missing task2_26_reference_stage.py before submission" >&2
  exit 2
}

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
WORKER_ID=1
FIXED_SEED=108
EPISODES_PER_WORKER=4
CPUS_PER_TASK="${CPUS_PER_TASK:-8}"
MEM_MB="${MEM_MB:-160000}"
WALLTIME="${WALLTIME:-01:00:00}"
SLURM_PARTITION="${SLURM_PARTITION:-acd_ue}"
EXCLUDE_NODE="${EXCLUDE_NODE:-ACD1-11}"
BATCH_ROOT="${OUTPUT_ROOT}/task24_v137_v131_fixedseed108_worker1_retry_${STAMP}"
RUNTIME_ENV="${BATCH_ROOT}/worker1.env"
mkdir -p "${BATCH_ROOT}/worker1"
[[ -z "$(git -C "${REPO_DIR}" status --porcelain -- "${REL_VERSION}" 2>/dev/null)" ]] || {
  echo "refuse to launch from a dirty v137 version directory" >&2
  exit 2
}
FROZEN_COMMIT="$(git -C "${REPO_DIR}" rev-parse HEAD)"
cp -a "${VERSION_DIR}" "${BATCH_ROOT}/code_snapshot_v137"
printf 'status=started\nfixed_seed=%s\nworker_id=%s\nreplaced_node=%s\npartition=%s\nwalltime=%s\nfrozen_commit=%s\n' \
  "${FIXED_SEED}" "${WORKER_ID}" "${EXCLUDE_NODE}" "${SLURM_PARTITION}" "${WALLTIME}" "${FROZEN_COMMIT}" >"${BATCH_ROOT}/LIVE_STATUS.txt"

umask 007
{
  printf 'export PRIVATE_INPUTS_FILE=%q\n' "${PRIVATE_INPUTS_FILE}"
  printf 'export BATCH_ROOT=%q\n' "${BATCH_ROOT}"
  printf 'export WORKER_ID=%q\n' "${WORKER_ID}"
  printf 'export BASE_PORT=%q\n' "10410"
  printf 'export FIXED_SEED=%q\n' "${FIXED_SEED}"
  printf 'export EPISODES_PER_WORKER=%q\n' "${EPISODES_PER_WORKER}"
} >"${RUNTIME_ENV}"
chmod 600 "${RUNTIME_ENV}"

SESSION="task24_v137_${STAMP}_worker1"
JOB_NAME="task24v137_${STAMP}_worker1"
RUNNER_Q="$(printf '%q' "${VERSION_DIR}/run_worker.sh")"
ENV_Q="$(printf '%q' "${RUNTIME_ENV}")"
LOG_Q="$(printf '%q' "${BATCH_ROOT}/worker1/submit.log")"
INNER="set -o pipefail; srun -p ${SLURM_PARTITION} --nodes=1 --ntasks=1 --gres=gpu:2 --exclude=${EXCLUDE_NODE} -c${CPUS_PER_TASK} --mem=${MEM_MB}M --time=${WALLTIME} --job-name=${JOB_NAME} bash ${RUNNER_Q} ${ENV_Q} 2>&1 | tee -a ${LOG_Q}; rc=\${PIPESTATUS[0]}; echo \"[TMUX_EXIT] status=\${rc}\"; exit \${rc}"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc $(printf '%q' "${INNER}")"
printf 'status=submitted\nsession=%s\njob_name=%s\nsubmitted_at=%s\n' \
  "${SESSION}" "${JOB_NAME}" "$(date -Is)" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
printf '%s\n' "${BATCH_ROOT}"
