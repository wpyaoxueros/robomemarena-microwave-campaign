#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUBMIT="${ROOT}/scripts/submit_archived_original_snapshot_topology.sh"
PROBE="${ROOT}/scripts/probe_and_submit_archived_original_snapshot_topology.sh"

for path in "${SUBMIT}" "${PROBE}"; do
  [[ -f "${path}" ]]
  bash -n "${path}"
done

grep -Fq 'run_archived_original_snapshot_topology.sh' "${SUBMIT}"
grep -Fq -- '--gres=gpu:2' "${SUBMIT}"
grep -Fq 'tmux -f /dev/null new-session' "${SUBMIT}"
grep -Fq 'probe_partition onegpu 1 1 1024' "${PROBE}"
grep -Fq 'probe_partition twogpu 2 16 327680' "${PROBE}"
grep -Fq 'acd_u acd_ue emergency_acd' "${PROBE}"

echo 'PASS archived original snapshot submit contract'
