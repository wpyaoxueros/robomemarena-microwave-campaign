#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v133_fixed_seed107_pinned_fastnodes_v132"

for file in "${VERSION}/PRE_RUN.md" "${VERSION}/dispatch_20ep_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'FAST_NODES=ACD1-3,ACD1-4,ACD1-6,ACD1-9,ACD1-38' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--nodelist=${FAST_NODES}' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--nodes=5' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q -- '--ntasks-per-node=1' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'v131_fixed_seed107_five_nodes_v130' "${VERSION}/dispatch_20ep_zzhang510.sh"
echo 'task21 v133 fixed-seed107 pinned-fast-node contract: PASS'
