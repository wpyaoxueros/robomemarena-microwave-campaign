#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_archived_repro20_historical_topology.sh"
SUBMITTER="${ROOT}/scripts/submit_archived_repro20_historical_topology.sh"

[[ -x "${RUNNER}" ]]
[[ -x "${SUBMITTER}" ]]

grep -Fq 'TASK_ID=${1:?usage:' "${RUNNER}"
grep -Fq 'case "${TASK_ID}" in' "${RUNNER}"
for task in 1 2 3 12 13 18 25 26; do
  grep -Fq "  ${task})" "${RUNNER}"
done
grep -Fq 'repro20_remote_metrics_20260704_175011' "${RUNNER}"
grep -Fq '66e7894f8188be8114911e5df0f8bf89fe4581ce' "${RUNNER}"
grep -Fq '70005b0564cedc38ac7ada01bdfdf82af49d7c170749acf5a8631026ac3b75b3' "${RUNNER}"
grep -Fq '[[ ${#visible_gpus[@]} -eq 2 ]]' "${RUNNER}"
grep -Fq 'historical_vla_gpu=first-visible' "${RUNNER}"
grep -Fq 'historical_vlm_eval_gpu=second-visible' "${RUNNER}"
grep -Fq "printf 'historical_scorer_commit=%s\\n' \"\${OFFICIAL_COMMIT}\"" "${RUNNER}"
grep -Fq 'exec env OFFICIAL_OUTPUT_ROOT=' "${RUNNER}"
! grep -Fq 'd9f83ac' "${RUNNER}"
! grep -Fq 'single_gpu' "${RUNNER}"

grep -Fq -- '--gres=gpu:2' "${SUBMITTER}"
! grep -Fq -- '--gres=gpu:1' "${SUBMITTER}"
grep -Fq 'tmux -f /dev/null new-session' "${SUBMITTER}"
grep -Fq 'run_archived_repro20_historical_topology.sh' "${SUBMITTER}"

echo 'PASS archived repro20 historical two-GPU topology contract'
