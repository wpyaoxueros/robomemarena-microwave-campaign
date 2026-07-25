#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_archived_repro20_historical_topology.sh"
SUBMITTER="${ROOT}/scripts/submit_archived_repro20_historical_topology.sh"
PROBE_SUBMITTER="${ROOT}/scripts/probe_and_submit_archived_repro20_historical_topology.sh"

[[ -x "${RUNNER}" ]]
[[ -x "${SUBMITTER}" ]]
[[ -x "${PROBE_SUBMITTER}" ]]

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
grep -Fq 'GIT_CONFIG_KEY_0=safe.directory' "${RUNNER}"
grep -Fq 'GIT_CONFIG_VALUE_0="${REPO_DIR}"' "${RUNNER}"
grep -Fq 'CAMPAIGN_GIT_COMMIT=${CAMPAIGN_GIT_COMMIT:?set CAMPAIGN_GIT_COMMIT before entering the compute node}' "${RUNNER}"
grep -Fq '"${CAMPAIGN_GIT_COMMIT}"' "${RUNNER}"
grep -Fq 'exec env OFFICIAL_OUTPUT_ROOT=' "${RUNNER}"
! grep -Fq 'd9f83ac' "${RUNNER}"
! grep -Fq 'single_gpu' "${RUNNER}"

grep -Fq -- '--gres=gpu:2' "${SUBMITTER}"
! grep -Fq -- '--gres=gpu:1' "${SUBMITTER}"
grep -Fq 'PARTITION=${PARTITION:-acd_u}' "${SUBMITTER}"
grep -Fq "srun -p \\\"\${PARTITION}\\\"" "${SUBMITTER}"
grep -Fq 'CAMPAIGN_GIT_COMMIT=${CAMPAIGN_GIT_COMMIT:-$(git -c safe.directory="${REPO_DIR}" -C "${REPO_DIR}" rev-parse HEAD)}' "${SUBMITTER}"
grep -Fq 'CAMPAIGN_GIT_COMMIT=${CAMPAIGN_GIT_COMMIT}' "${SUBMITTER}"
grep -Fq 'tmux -f /dev/null new-session' "${SUBMITTER}"
grep -Fq 'run_archived_repro20_historical_topology.sh' "${SUBMITTER}"

grep -Fq 'for part in acd_u acd_ue emergency_acd' "${PROBE_SUBMITTER}"
grep -Fq -- '--gres="gpu:${gpus}"' "${PROBE_SUBMITTER}"
grep -Fq 'timeout 25s srun --immediate=20' "${PROBE_SUBMITTER}"
grep -Fq 'scancel --name="${probe_name}" -u "$(id -un)"' "${PROBE_SUBMITTER}"
grep -Fq '>&2' "${PROBE_SUBMITTER}"
grep -Fq 'TWO_GPU_PARTITION="$(probe_partition' "${PROBE_SUBMITTER}"
grep -Fq 'PARTITION="${TWO_GPU_PARTITION}"' "${PROBE_SUBMITTER}"
grep -Fq 'submit_archived_repro20_historical_topology.sh' "${PROBE_SUBMITTER}"

echo 'PASS archived repro20 historical two-GPU topology contract'
