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
FIXED_SEED=108
WORKERS=5
EPISODES_PER_WORKER=4
CPUS_PER_TASK="${CPUS_PER_TASK:-8}"
MEM_MB="${MEM_MB:-160000}"
WALLTIME="${WALLTIME:-01:00:00}"
SLURM_PARTITION="${SLURM_PARTITION:-acd_ue}"
SHARED_GROUP="${SHARED_GROUP:-irpn}"
[[ "${SLURM_PARTITION}" =~ ^(acd_u|acd_ue|emergency_acd)$ ]] || {
  echo "unsupported partition: ${SLURM_PARTITION}" >&2
  exit 2
}
BATCH_ROOT="${OUTPUT_ROOT}/task24_v136_v131_fixedseed108_20ep_independent_${STAMP}"
RUNTIME_ENV_DIR="${BATCH_ROOT}/runtime_env"
mkdir -p "${RUNTIME_ENV_DIR}"
[[ -z "$(git -C "${REPO_DIR}" status --porcelain -- "${REL_VERSION}" 2>/dev/null)" ]] || {
  echo "refuse to launch from a dirty v136 version directory" >&2
  exit 2
}
FROZEN_COMMIT="$(git -C "${REPO_DIR}" rev-parse HEAD)"
cp -a "${VERSION_DIR}" "${BATCH_ROOT}/code_snapshot_v136"
printf 'status=started\nstarted_at=%s\nfixed_seed=%s\nworkers=%s\nepisodes_per_worker=%s\ntotal_attempts=%s\npartition=%s\nmem_mb_per_node=%s\nwalltime=%s\nfrozen_commit=%s\nscheduling=independent_single_node_workers\n' \
  "$(date -Is)" "${FIXED_SEED}" "${WORKERS}" "${EPISODES_PER_WORKER}" "$((WORKERS * EPISODES_PER_WORKER))" \
  "${SLURM_PARTITION}" "${MEM_MB}" "${WALLTIME}" "${FROZEN_COMMIT}" >"${BATCH_ROOT}/LIVE_STATUS.txt"

umask 077
for worker_id in 0 1 2 3 4; do
  runtime_env="${RUNTIME_ENV_DIR}/worker${worker_id}.env"
  {
    printf 'export PRIVATE_INPUTS_FILE=%q\n' "${PRIVATE_INPUTS_FILE}"
    printf 'export BATCH_ROOT=%q\n' "${BATCH_ROOT}"
    printf 'export WORKER_ID=%q\n' "${worker_id}"
    printf 'export BASE_PORT=%q\n' "$((10300 + worker_id * 10))"
    printf 'export FIXED_SEED=%q\n' "${FIXED_SEED}"
    printf 'export EPISODES_PER_WORKER=%q\n' "${EPISODES_PER_WORKER}"
  } >"${runtime_env}"
  chmod 600 "${runtime_env}"

  session="task24_v136_${STAMP}_worker${worker_id}"
  job_name="task24v136_${STAMP}_worker${worker_id}"
  runner_q="$(printf '%q' "${VERSION_DIR}/run_worker.sh")"
  env_q="$(printf '%q' "${runtime_env}")"
  submit_log="${BATCH_ROOT}/worker${worker_id}/submit.log"
  mkdir -p "${BATCH_ROOT}/worker${worker_id}"
  chgrp "${SHARED_GROUP}" "${BATCH_ROOT}/worker${worker_id}"
  chmod 2770 "${BATCH_ROOT}/worker${worker_id}"
  inner="set -o pipefail; srun -p ${SLURM_PARTITION} --nodes=1 --ntasks=1 --gres=gpu:2 -c${CPUS_PER_TASK} --mem=${MEM_MB}M --time=${WALLTIME} --job-name=${job_name} bash ${runner_q} ${env_q} 2>&1 | tee -a $(printf '%q' "${submit_log}"); rc=\${PIPESTATUS[0]}; echo \"[TMUX_EXIT] status=\${rc}\"; exit \${rc}"
  tmux -f /dev/null -L hlei573borrow new-session -d -s "${session}" \
    "bash -lc $(printf '%q' "${inner}")"
  printf 'worker%s_session=%s\nworker%s_job_name=%s\n' "${worker_id}" "${session}" "${worker_id}" "${job_name}" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
done

printf 'status=submitted\nsubmitted_at=%s\n' "$(date -Is)" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
printf '%s\n' "${BATCH_ROOT}"
