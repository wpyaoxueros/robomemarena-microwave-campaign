#!/usr/bin/env bash
set -euo pipefail

STAMP=${1:-$(date +%Y%m%d_%H%M%S)}
ROOT=${OFFICIAL_OUTPUT_ROOT:-/data/user/zzhang510/hlei573_borrow_outputs/repro20_fullrollout_official_${STAMP}}
TASKS=${TASKS:-"1 2 3 12 13 18 25 26"}
REPO=/data/user/hlei573/vla_memory_experiments
RUN_ONE=${REPO}/english_ref_vlm26/repro20_remote_metrics_20260704_175011/run_one.sh

mkdir -p "${ROOT}/launch_logs"
cp -p "$0" "${ROOT}/launch_logs/launch_fullrollout_repro20.sh"

for TASK in ${TASKS}; do
  SESSION="r20full_t${TASK}_${STAMP}"
  JOB="r20full_t${TASK}_${STAMP}"
  LOG="${ROOT}/launch_logs/task${TASK}.log"
  tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
    "bash -lc 'cd ${REPO} && \
      echo SUBMIT_USER=\$(whoami) HOST=\$(hostname) ROOT=${ROOT} TASK=${TASK} JOB=${JOB}; \
      srun -p acd_u --gres=gpu:2 -c16 --mem=160G --time=10:00:00 --job-name=${JOB} \
        bash -lc \"cd ${REPO} && OFFICIAL_OUTPUT_ROOT=${ROOT} OFFICIAL_RUN_STAMP=${STAMP}_t${TASK} bash ${RUN_ONE} ${TASK}\"' \
      2>&1 | tee -a ${LOG}"
  echo "launched ${SESSION} ${LOG}"
done

echo "ROOT=${ROOT}"
tmux -L hlei573borrow ls | grep "r20full_.*_${STAMP}" || true
squeue -u "$(whoami)" -o "%.18i %.10u %.36j %.10T %.10M %.20R" | head -60
