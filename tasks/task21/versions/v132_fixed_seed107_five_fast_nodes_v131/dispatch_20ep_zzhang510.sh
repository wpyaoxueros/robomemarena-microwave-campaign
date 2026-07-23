#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from the zzhang510 shell" >&2; exit 2; }
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are unreadable" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
V131_DIR="${PACK_DIR}/versions/v131_fixed_seed107_five_nodes_v130"
V130_DIR="${PACK_DIR}/versions/v130_fixed_seed107_repeat20_v127"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
FIXED_SEED=107
REPEATS=4
EXCLUDE_NODES=ACD1-39,ACD1-40
BASE_PORTS=(9900 9920 9940 9960 9980)
PARTITIONS=(acd_u acd_ue emergency_acd)
CPUS_PER_TASK=8
BATCH_ROOT="${OUTPUT_ROOT}/task21_v132_fixedseed107_fivefastnodes_repeat20_${STAMP}"
RUNTIME_ENV_DIR="${BATCH_ROOT}/runtime_env"
mkdir -p "${RUNTIME_ENV_DIR}"
cp -p "${VERSION_DIR}/PRE_RUN.md" "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" "${BATCH_ROOT}/"
cp -p "${V131_DIR}/run_multinode_worker.sh" "${BATCH_ROOT}/V131_run_multinode_worker.sh"
cp -p "${V131_DIR}/PRE_RUN.md" "${BATCH_ROOT}/V131_PRE_RUN.md"
cp -p "${V130_DIR}/PRE_RUN.md" "${BATCH_ROOT}/V130_PRE_RUN.md"
cp -p "${V130_DIR}/run_worker.sh" "${V130_DIR}/validate_episode.py" \
  "${V130_DIR}/aggregate_fixedseed20.py" "${BATCH_ROOT}/"
printf 'status=started\nstarted_at=%s\nfixed_seed=%s\nworkers=5\nrepeats_per_worker=%s\nrequested_nodes=5\nexcluded_nodes=%s\n' \
  "$(date -Is)" "${FIXED_SEED}" "${REPEATS}" "${EXCLUDE_NODES}" >"${BATCH_ROOT}/LIVE_STATUS.txt"

PARTITION=""
for candidate in "${PARTITIONS[@]}"; do
  if srun --immediate=20 -p "${candidate}" --exclude="${EXCLUDE_NODES}" --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
    --job-name="task21v132probe_${STAMP}" bash -lc 'nvidia-smi --query-gpu=name --format=csv,noheader | head -1 >/dev/null' </dev/null; then
    PARTITION="${candidate}"
    break
  fi
done
[[ -n "${PARTITION}" ]] || { echo "no usable fast-node GPU probe succeeded" >&2; exit 3; }
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
    printf 'export FIXED_SEED=%q\n' "${FIXED_SEED}"
    printf 'export REPEATS=%q\n' "${REPEATS}"
  } >"${runtime_env}"
  chmod 600 "${runtime_env}"
done

SESSION="task21_v132_${STAMP}_five_fast_nodes"
JOB_NAME="task21v132_${STAMP}_five_fast_nodes"
RUNNER_Q="$(printf '%q' "${V131_DIR}/run_multinode_worker.sh")"
ENV_DIR_Q="$(printf '%q' "${RUNTIME_ENV_DIR}")"
LOG_Q="$(printf '%q' "${BATCH_ROOT}/submit.log")"
TASK_LOG="${BATCH_ROOT}/slurm-%t.log"
INNER="set -o pipefail; srun -p ${PARTITION} --exclude=${EXCLUDE_NODES} --nodes=5 --ntasks=5 --ntasks-per-node=1 --gres=gpu:2 -c${CPUS_PER_TASK} --mem=${MEM_MB}M --time=02:00:00 --job-name=${JOB_NAME} --output=${TASK_LOG} bash ${RUNNER_Q} ${ENV_DIR_Q} 2>&1 | tee -a ${LOG_Q}; rc=\${PIPESTATUS[0]}; echo \"[TMUX_EXIT] status=\${rc}\"; exit \${rc}"
tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc $(printf '%q' "${INNER}")"

printf 'status=submitted\nsession=%s\njob_name=%s\npartition=%s\nrequested_nodes=5\nexcluded_nodes=%s\nfinished_at=%s\n' \
  "${SESSION}" "${JOB_NAME}" "${PARTITION}" "${EXCLUDE_NODES}" "$(date -Is)" >>"${BATCH_ROOT}/LIVE_STATUS.txt"
printf '%s\n' "${BATCH_ROOT}"
