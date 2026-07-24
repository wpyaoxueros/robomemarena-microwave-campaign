#!/usr/bin/env bash
set -euo pipefail

# Execute this script as zzhang510 from inside one tmux session. It performs
# fresh account probes in that same shell before launching the formal jobs.

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_PRIVATE_ROOT=${RUNTIME_PRIVATE_ROOT:?set RUNTIME_PRIVATE_ROOT}
OFFICIAL_OUTPUT_ROOT=${OFFICIAL_OUTPUT_ROOT:?set OFFICIAL_OUTPUT_ROOT}
TASKS=${TASKS:-"1 3 12 13 18 25 26"}
CPUS=${CPUS:-8}
TIME_LIMIT=${TIME_LIMIT:-12:00:00}
STAMP=${STAMP:-$(date +%Y%m%d_%H%M%S)}

mkdir -p "${OFFICIAL_OUTPUT_ROOT}/probes" "${OFFICIAL_OUTPUT_ROOT}/submissions"
PROBE_LOG="${OFFICIAL_OUTPUT_ROOT}/probes/zzhang510_archived_exact20_${STAMP}.log"

probe_shape() {
  local partition=$1
  local gpus=$2
  local max_per_cpu mem_mb
  max_per_cpu="$(scontrol show partition "${partition}" | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p')"
  [[ -n "${max_per_cpu}" ]] || max_per_cpu=20480
  mem_mb=$((CPUS * max_per_cpu))

  echo "[PROBE] partition=${partition} gpus=${gpus} cpus=${CPUS} mem=${mem_mb}M" | tee -a "${PROBE_LOG}"
  srun --immediate=20 -p "${partition}" --gres="gpu:${gpus}" -c "${CPUS}" \
    --mem="${mem_mb}M" --time=00:02:00 \
    --job-name="d9exact20_probe_g${gpus}_${STAMP}" \
    bash -lc "set -euo pipefail; echo user=\$(whoami); echo host=\$(hostname); echo slurm_job=\${SLURM_JOB_ID}; nvidia-smi -L; probe_root='${OFFICIAL_OUTPUT_ROOT}/probes'; mkdir -p \"\${probe_root}/compute_write_\${SLURM_JOB_ID}\"; touch \"\${probe_root}/compute_write_\${SLURM_JOB_ID}/ok\"" \
    2>&1 | tee -a "${PROBE_LOG}"
}

PARTITION=
for candidate in acd_u acd_ue emergency_acd; do
  if probe_shape "${candidate}" 1 && probe_shape "${candidate}" 2; then
    PARTITION=${candidate}
    break
  fi
done
[[ -n "${PARTITION}" ]] || { echo "[ERROR] no fresh 1/2-GPU probe succeeded" | tee -a "${PROBE_LOG}" >&2; exit 1; }

MAX_MEM_PER_CPU_MB="$(scontrol show partition "${PARTITION}" | sed -n 's/.*MaxMemPerCPU=\([0-9][0-9]*\).*/\1/p')"
[[ -n "${MAX_MEM_PER_CPU_MB}" ]] || MAX_MEM_PER_CPU_MB=20480
FORMAL_MEM_MB=$((CPUS * MAX_MEM_PER_CPU_MB))

echo "[INFO] selected_partition=${PARTITION} formal_mem=${FORMAL_MEM_MB}M" | tee -a "${PROBE_LOG}"
printf 'submit_user=%s\nselected_partition=%s\nstamp=%s\ntasks=%s\n' "$(whoami)" "${PARTITION}" "${STAMP}" "${TASKS}" \
  > "${OFFICIAL_OUTPUT_ROOT}/submissions/archived_exact20_${STAMP}.manifest"

for task in ${TASKS}; do
  runtime_env="${RUNTIME_PRIVATE_ROOT}/archived_task${task}.env"
  [[ -f "${runtime_env}" ]] || { echo "[ERROR] missing ${runtime_env}" >&2; exit 2; }

  session="d9exact20_t${task}_${STAMP}"
  job_name="d9exact20_t${task}_${STAMP}"
  submit_log="${OFFICIAL_OUTPUT_ROOT}/submissions/task${task}_${STAMP}.log"
  command="cd '${CAMPAIGN_DIR}' && RUNTIME_ENV='${runtime_env}' PORT=$((9400 + task)) srun -p '${PARTITION}' --gres=gpu:2 -c '${CPUS}' --mem='${FORMAL_MEM_MB}M' --time='${TIME_LIMIT}' --job-name='${job_name}' bash 'scripts/run_archived_exact20_inside_allocation.sh' '${task}' '${runtime_env}' 2>&1 | tee -a '${submit_log}'; rc=\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\${rc}; exec bash"
  tmux new-session -d -s "${session}" "bash -lc \"${command}\""
  printf 'task=%s\ntmux=%s\nlog=%s\n' "${task}" "${session}" "${submit_log}" \
    > "${OFFICIAL_OUTPUT_ROOT}/submissions/task${task}_${STAMP}.submission"
done

echo "[INFO] launched task sessions: ${TASKS}" | tee -a "${PROBE_LOG}"
