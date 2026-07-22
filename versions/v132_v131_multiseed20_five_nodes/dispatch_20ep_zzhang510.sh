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

# The scorer checkout is owned by the workspace account while this job is
# submitted by zzhang510. Registering it as safe only permits the immutable
# commit check below; it does not alter evaluator code or scoring behavior.
# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
OUTPUT_ROOT="${CALLER_OUTPUT_ROOT}"
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

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
SEED_START=104
EPISODES_PER_WORKER=4
FAST_NODES=ACD1-3,ACD1-4,ACD1-6,ACD1-9,ACD1-38
BASE_PORTS=(10100 10120 10140 10160 10180)
PARTITIONS=(acd_u acd_ue emergency_acd)
CPUS_PER_TASK=8
BATCH_ROOT="${OUTPUT_ROOT}/task24_v132_v131_multiseed20_fivenodes_${STAMP}"
RUNTIME_ENV_DIR="${BATCH_ROOT}/runtime_env"
mkdir -p "${RUNTIME_ENV_DIR}"
[[ -z "$(git -C "${REPO_DIR}" status --porcelain -- "${REL_VERSION}" 2>/dev/null)" ]] || {
  echo "refuse to launch from a dirty v132 version directory" >&2
  exit 2
}
FROZEN_COMMIT="$(git -C "${REPO_DIR}" rev-parse HEAD)"
cp -a "${VERSION_DIR}" "${BATCH_ROOT}/code_snapshot_v132"
printf 'status=started\nstarted_at=%s\nseed_start=%s\nseed_end=%s\nworkers=5\nepisodes_per_worker=%s\nrequested_nodes=5\nfast_nodes=%s\nfrozen_commit=%s\n' \
  "$(date -Is)" "${SEED_START}" "$((SEED_START + 19))" "${EPISODES_PER_WORKER}" "${FAST_NODES}" "${FROZEN_COMMIT}" >"${BATCH_ROOT}/LIVE_STATUS.txt"

PARTITION=""
for candidate in "${PARTITIONS[@]}"; do
  if srun --immediate=20 -p "${candidate}" --nodelist="${FAST_NODES}" --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
    --job-name="task24v132probe_${STAMP}" bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null; then
    PARTITION="${candidate}"
    break
  fi
done
[[ -n "${PARTITION}" ]] || { echo "no five-node GPU probe succeeded" >&2; exit 3; }
MAX_MEM_PER_CPU_MB="$(scontrol show partition "${PARTITION}" | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p' | head -1)"
MEM_MB="${MEM_MB:-$((CPUS_PER_TASK * ${MAX_MEM_PER_CPU_MB:-20480}))}"
printf 'probe=passed\npartition=%s\nprobe_finished=%s\nmem_mb=%s\n' \
  "${PARTITION}" "$(date -Is)" "${MEM_MB}" >>"${BATCH_ROOT}/LIVE_STATUS.txt"

umask 077
for worker_id in 0 1 2 3 4; do
  runtime_env="${RUNTIME_ENV_DIR}/worker${worker_id}.env"
  {
    printf 'export PRIVATE_INPUTS_FILE=%q\n' "${PRIVATE_INPUTS_FILE}"
    printf 'export BATCH_ROOT=%q\n' "${BATCH_ROOT}"
    printf 'export WORKER_ID=%q\n' "${worker_id}"
    printf 'export BASE_PORT=%q\n' "${BASE_PORTS[$worker_id]}"
    printf 'export SEED_START=%q\n' "${SEED_START}"
    printf 'export EPISODES_PER_WORKER=%q\n' "${EPISODES_PER_WORKER}"
  } >"${runtime_env}"
  chmod 600 "${runtime_env}"
done

SESSION="task24_v132_${STAMP}_five_nodes"
JOB_NAME="task24v132_${STAMP}_five_nodes"
RUNNER_Q="$(printf '%q' "${VERSION_DIR}/run_multinode_worker.sh")"
ENV_DIR_Q="$(printf '%q' "${RUNTIME_ENV_DIR}")"
LOG_Q="$(printf '%q' "${BATCH_ROOT}/submit.log")"
TASK_LOG="${BATCH_ROOT}/slurm-%t.log"
INNER="set -o pipefail; srun -p ${PARTITION} --nodelist=${FAST_NODES} --nodes=5 --ntasks=5 --ntasks-per-node=1 --gres=gpu:2 -c${CPUS_PER_TASK} --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} --output=${TASK_LOG} bash ${RUNNER_Q} ${ENV_DIR_Q} 2>&1 | tee -a ${LOG_Q}; rc=\${PIPESTATUS[0]}; echo \"[TMUX_EXIT] status=\${rc}\"; exit \${rc}"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc $(printf '%q' "${INNER}")"

printf 'status=submitted\nsession=%s\njob_name=%s\npartition=%s\nrequested_nodes=5\nfast_nodes=%s\nsubmitted_at=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${PARTITION}" "${FAST_NODES}" "$(date -Is)" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
printf '%s\n' "${BATCH_ROOT}"
