#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v127_single_seed107_serial_replay"
ROOT_RUNNER="${REPO}/scripts/run_task21_v121.sh"

for file in "${VERSION}/PRE_RUN.md" "${VERSION}/run_one.sh" "${VERSION}/submit_one_zzhang510.sh" "${VERSION}/dispatch_after_probe_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done
bash -n "${VERSION}/run_one.sh" "${VERSION}/submit_one_zzhang510.sh" "${VERSION}/dispatch_after_probe_zzhang510.sh"
rg -q 'v127 is fixed to seed107' "${VERSION}/run_one.sh"
rg -q 'SEED=107' "${VERSION}/submit_one_zzhang510.sh"
rg -q 'PORT=9801' "${VERSION}/dispatch_after_probe_zzhang510.sh"
rg -q 'ORACLE_HOLD_RELEASE_NEXT=0' "${ROOT_RUNNER}"
rg -q 'ORACLE_FORCE_INITIAL_PROMPT=0' "${ROOT_RUNNER}"
rg -q 'ORACLE_STAGE_ADVANCE_NEXT=0' "${ROOT_RUNNER}"
rg -q '"tasks": \{\}' "${VERSION}/release_anchors.empty.object.json"
rg -q '</dev/null' "${VERSION}/dispatch_after_probe_zzhang510.sh"
echo 'task21 v127 serial replay contract: PASS'
