#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_VERSION_DIR="${VERSION_DIR}/../v132_v131_multiseed20_five_nodes"
REPO_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
REL_VERSION="${VERSION_DIR#${REPO_DIR}/}"
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are unreadable" >&2; exit 2; }

# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
: "${ROBOMEMARENA_REMOTE_ROOT:?private inputs must define ROBOMEMARENA_REMOTE_ROOT}"
git config --global --add safe.directory "${REPO_DIR}"
git config --global --add safe.directory "${ROBOMEMARENA_REMOTE_ROOT}"
EXPECTED_OFFICIAL_COMMIT=62214036103ee8d5fef9b475dd8b344b6e2cfc03
ACTUAL_OFFICIAL_COMMIT="$(git -C "${ROBOMEMARENA_REMOTE_ROOT}" rev-parse HEAD)"
[[ "${ACTUAL_OFFICIAL_COMMIT}" == "${EXPECTED_OFFICIAL_COMMIT}" ]] || {
  echo "official scorer mismatch before submission" >&2
  exit 2
}
[[ -r "${ROBOMEMARENA_REMOTE_ROOT}/evaluation_benchmark/scripts/task2_26_reference_stage.py" ]] || {
  echo "missing task2_26_reference_stage.py before submission" >&2
  exit 2
}
[[ -x "${SOURCE_VERSION_DIR}/run_one.sh" ]] || { echo "missing frozen v132 runtime" >&2; exit 2; }
[[ -z "$(git -C "${REPO_DIR}" status --porcelain -- "${REL_VERSION}" "${SOURCE_VERSION_DIR#${REPO_DIR}/}")" ]] || {
  echo "refuse to launch from a dirty retry/runtime directory" >&2
  exit 2
}

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
PARTITION=acd_u
CPUS_PER_TASK=8
MAX_MEM_PER_CPU_MB="$(scontrol show partition "${PARTITION}" | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p' | head -1)"
MEM_MB="${MEM_MB:-$((CPUS_PER_TASK * ${MAX_MEM_PER_CPU_MB:-20480}))}"
EXCLUDE_NODE="${EXCLUDE_NODE:-ACD1-1}"
GPU_PREFLIGHT_MAX_MIB="${GPU_PREFLIGHT_MAX_MIB:-4096}"
RETRY_SEEDS=(104 105 106 107)
BASE_PORTS=(10200 10220 10240 10260)
BATCH_ROOT="${OUTPUT_ROOT}/task24_v133_v132_clean_retry_104_107_${STAMP}"
RUNTIME_ENV_DIR="${BATCH_ROOT}/runtime_env"
mkdir -p "${RUNTIME_ENV_DIR}"
FROZEN_COMMIT="$(git -C "${REPO_DIR}" rev-parse HEAD)"
cp -a "${VERSION_DIR}" "${BATCH_ROOT}/code_snapshot_v133"
cp -a "${SOURCE_VERSION_DIR}" "${BATCH_ROOT}/code_snapshot_v132"
printf 'status=started\nstarted_at=%s\nretry_seeds=%s\nexcluded_node=%s\nscorer_commit=%s\nfrozen_commit=%s\n' \
  "$(date -Is)" "${RETRY_SEEDS[*]}" "${EXCLUDE_NODE}" "${EXPECTED_OFFICIAL_COMMIT}" "${FROZEN_COMMIT}" >"${BATCH_ROOT}/LIVE_STATUS.txt"

umask 077
for worker_id in 0 1 2 3; do
  runtime_env="${RUNTIME_ENV_DIR}/worker${worker_id}.env"
  {
    printf 'export PRIVATE_INPUTS_FILE=%q\n' "${PRIVATE_INPUTS_FILE}"
    printf 'export BATCH_ROOT=%q\n' "${BATCH_ROOT}"
    printf 'export WORKER_ID=%q\n' "${worker_id}"
    printf 'export RETRY_SEED=%q\n' "${RETRY_SEEDS[$worker_id]}"
    printf 'export BASE_PORT=%q\n' "${BASE_PORTS[$worker_id]}"
    printf 'export GPU_PREFLIGHT_MAX_MIB=%q\n' "${GPU_PREFLIGHT_MAX_MIB}"
  } >"${runtime_env}"
  chmod 600 "${runtime_env}"
done

SESSION="task24_v133_${STAMP}_clean_retry"
JOB_NAME="task24v133_${STAMP}_clean_retry"
PROBE_NAME="task24v133probe_${STAMP}"
RUNNER_Q="$(printf '%q' "${VERSION_DIR}/run_retry_multinode_worker.sh")"
ENV_DIR_Q="$(printf '%q' "${RUNTIME_ENV_DIR}")"
LOG_Q="$(printf '%q' "${BATCH_ROOT}/submit.log")"
TASK_LOG="${BATCH_ROOT}/slurm-%t.log"
INNER="set -o pipefail; srun -p ${PARTITION} --immediate=20 --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 --job-name=${PROBE_NAME} bash -lc 'hostname'; echo '[ACCOUNT_PROBE] passed'; srun -p ${PARTITION} --exclude=${EXCLUDE_NODE} --nodes=4 --ntasks=4 --ntasks-per-node=1 --gres=gpu:2 -c${CPUS_PER_TASK} --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} --output=${TASK_LOG} bash ${RUNNER_Q} ${ENV_DIR_Q} 2>&1 | tee -a ${LOG_Q}; rc=\${PIPESTATUS[0]}; echo \"[TMUX_EXIT] status=\${rc}\"; exit \${rc}"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc $(printf '%q' "${INNER}")"

printf 'status=submitted\nsession=%s\njob_name=%s\nrequested_nodes=4\nmem_mb=%s\nsubmitted_at=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${MEM_MB}" "$(date -Is)" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
printf '%s\n' "${BATCH_ROOT}"
