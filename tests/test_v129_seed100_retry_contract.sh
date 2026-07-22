#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v129_seed100_exclude_acd1_61_retry"

[[ -s "${VERSION}/RETRY.md" ]]
[[ -s "${VERSION}/submit_seed100_zzhang510.sh" ]]
[[ -s "${VERSION}/run_worker.sh" ]]
bash -n "${VERSION}/submit_seed100_zzhang510.sh"
bash -n "${VERSION}/run_worker.sh"
rg -F -q 'SEED="${SEED:-100}"' "${VERSION}/submit_seed100_zzhang510.sh"
rg -F -q '[[ "${SEED}" == "100" ]]' "${VERSION}/submit_seed100_zzhang510.sh"
rg -F -q -- '--exclude=ACD1-61' "${VERSION}/submit_seed100_zzhang510.sh"
rg -F -q 'NUM_TRIALS=4' "${VERSION}/submit_seed100_zzhang510.sh"
rg -F -q 'V128_DIR="${VERSION_DIR}/../v128_v121_20ep_sharded_latest622"' "${VERSION}/run_worker.sh"
rg -F -q 'exec bash "${V128_DIR}/run_shard.sh"' "${VERSION}/run_worker.sh"
echo 'task21 v129 seed100 retry contract: PASS'
