#!/usr/bin/env bash
set -euo pipefail

ROOT=/data/user/zzhang510/hlei573_borrow_outputs/repro20_official66e789_retry13_18_20260704_210400
SOURCE_ROOT=/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/repro20_remote_metrics_20260704_175011
TASKS=(13 18)
CPUS=16
MEM_MB=327680
EXCLUDE_NODE=ACD1-58
STAMP=repro20_official66e789_retry13_18_20260704_210400

mkdir -p "${ROOT}"

for task in "${TASKS[@]}"; do
  session="r20off_retry_t${task}_210400"
  job="r20off_retry_t${task}_210400"
  log="${ROOT}/task${task}/slurm_submit.log"
  mkdir -p "${ROOT}/task${task}"
  tmux -f /dev/null -L hlei573borrow new-session -d -s "${session}" \
    "bash -lc 'export OFFICIAL_OUTPUT_ROOT=${ROOT}; export OFFICIAL_RUN_STAMP=${STAMP}; srun -p acd_u --exclude=${EXCLUDE_NODE} --gres=gpu:2 -c ${CPUS} --mem=${MEM_MB}M --time=08:00:00 --job-name=${job} bash -lc \"cd ${SOURCE_ROOT} && bash ${SOURCE_ROOT}/run_one.sh ${task}\" 2>&1 | tee -a ${log}'"
done

tmux -L hlei573borrow ls
squeue -u "$(whoami)" -o '%.18i %.30j %.10T %.10M %.4D %R'
