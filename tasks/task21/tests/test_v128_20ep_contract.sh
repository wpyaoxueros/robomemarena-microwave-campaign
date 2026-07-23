#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v128_v121_20ep_sharded_latest622"

for file in \
  "${VERSION}/PRE_RUN.md" \
  "${VERSION}/run_shard.sh" \
  "${VERSION}/submit_shard_zzhang510.sh" \
  "${VERSION}/dispatch_20ep_zzhang510.sh" \
  "${VERSION}/aggregate_20ep.py"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION}/run_shard.sh" "${VERSION}/submit_shard_zzhang510.sh" "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'NUM_TRIALS="${NUM_TRIALS:-4}"' "${VERSION}/run_shard.sh"
rg -F -q '100 104 108 112 116' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'for index in "${!BASE_SEEDS[@]}"' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'SEED="${base_seed}"' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'NUM_TRIALS=4' "${VERSION}/submit_shard_zzhang510.sh"
rg -F -q 'ORACLE_HOLD_RELEASE_NEXT=0' "${VERSION}/run_shard.sh"
rg -F -q 'ORACLE_STAGE_ADVANCE_NEXT=0' "${VERSION}/run_shard.sh"
rg -F -q 'release_anchors.empty.object.json' "${VERSION}/run_shard.sh"
rg -F -q 'task2_26_reference_stage.py' "${REPO}/scripts/launch_one_sync_hold_orig35999.sh"
echo 'task21 v128 20ep contract: PASS'
