#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v126_latest622_multiseed_replay"
ROOT_RUNNER="${REPO}/scripts/run_task21_v121.sh"

for file in "${VERSION}/PRE_RUN.md" "${VERSION}/run_one.sh" "${VERSION}/submit_one_zzhang510.sh" "${VERSION}/dispatch_after_probe_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done
rg -q '"tasks": \{\}' "${VERSION}/release_anchors.empty.object.json"
rg -q 'ORACLE_HOLD_RELEASE_NEXT=0' "${ROOT_RUNNER}"
rg -q 'ORACLE_FORCE_INITIAL_PROMPT=0' "${ROOT_RUNNER}"
rg -q 'ORACLE_STAGE_ADVANCE_NEXT=0' "${ROOT_RUNNER}"
rg -q 'TASK21_RELEASE_ANCHOR_TEMPLATE="\$\{VERSION_DIR\}/release_anchors.empty.object.json"' "${VERSION}/run_one.sh"
rg -q '</dev/null' "${VERSION}/dispatch_after_probe_zzhang510.sh"
rg -q "'107 9801' '108 9802' '109 9803'" "${VERSION}/dispatch_after_probe_zzhang510.sh"
echo 'task21 v126 contract: PASS'
