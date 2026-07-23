#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v132_fixed_seed107_five_fast_nodes_v131"

for file in "${VERSION}/PRE_RUN.md" "${VERSION}/dispatch_20ep_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'EXCLUDE_NODES=ACD1-39,ACD1-40' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--exclude=${EXCLUDE_NODES}' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--nodes=5' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--ntasks-per-node=1' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'versions/v131_fixed_seed107_five_nodes_v130' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q '"${V131_DIR}/run_multinode_worker.sh"' "${VERSION}/dispatch_20ep_zzhang510.sh"
echo 'task21 v132 fixed-seed107 fast-node contract: PASS'
