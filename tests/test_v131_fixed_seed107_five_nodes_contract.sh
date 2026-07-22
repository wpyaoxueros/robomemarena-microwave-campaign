#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v131_fixed_seed107_five_nodes_v130"

for file in \
  "${VERSION}/PRE_RUN.md" \
  "${VERSION}/run_multinode_worker.sh" \
  "${VERSION}/dispatch_20ep_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION}/run_multinode_worker.sh" "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--nodes=5' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--ntasks=5' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--ntasks-per-node=1' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--gres=gpu:2' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'FIXED_SEED=107' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'v130_fixed_seed107_repeat20_v127/run_worker.sh' "${VERSION}/run_multinode_worker.sh"
rg -F -q '"${BATCH_ROOT}/V130_PRE_RUN.md"' "${VERSION}/dispatch_20ep_zzhang510.sh"
echo 'task21 v131 fixed-seed107 five-node contract: PASS'
