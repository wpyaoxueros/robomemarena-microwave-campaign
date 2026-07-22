#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${REPO}/scripts/run_task24_v124_pick2place_robotonly_latest622_1ep.sh"
ANCHORS="${REPO}/config/release_anchors_t24_add_pick2place_robotonly_20260722.json"
PRE_RUN="${REPO}/versions/v124_pick2place_robotonly_smoke/PRE_RUN.md"

[[ -x "${RUNNER}" ]] || { echo "runner must be executable" >&2; exit 1; }
[[ -f "${PRE_RUN}" ]] || { echo "missing pre-run record" >&2; exit 1; }
[[ -x "${REPO}/versions/v124_pick2place_robotonly_smoke/submit_one_zzhang510.sh" ]] || {
  echo "missing reproducible Slurm/tmux submitter" >&2
  exit 1
}
rg -q 'STRICT_HOLD_RELEASE_NEXT=1' "${RUNNER}"
rg -q 'release_anchors_t24_add_pick2place_robotonly_20260722.json' "${RUNNER}"
rg -q 'private inputs are missing or unreadable' "${REPO}/versions/v124_pick2place_robotonly_smoke/run_one.sh"
rg -q 'ORACLE_HOLD_RELEASE_NEXT=0' "${REPO}/scripts/run_task23_24_v112_historicalvlm_eef_pickfinish50_latest622_1ep.sh"
rg -q '"object_anchor": false' "${ANCHORS}"
rg -q '"oracle_prompt": false' "${ANCHORS}"
rg -q '"released": "pick cookies"' "${ANCHORS}"
rg -q '"next": "place cookies"' "${ANCHORS}"
if rg -q 'object_mw|object_gate|object lift' "${RUNNER}" "${ANCHORS}"; then
  echo "v124 must not enable object-moving or object-gate controls" >&2
  exit 1
fi
echo 'PASS: Task24 v124 autonomous robot-only boundary contract'
