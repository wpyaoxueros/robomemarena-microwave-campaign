#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v130_fixed_seed107_repeat20_v127"

for file in \
  "${VERSION}/PRE_RUN.md" \
  "${VERSION}/run_worker.sh" \
  "${VERSION}/validate_episode.py" \
  "${VERSION}/submit_worker_zzhang510.sh" \
  "${VERSION}/dispatch_20ep_zzhang510.sh" \
  "${VERSION}/aggregate_fixedseed20.py"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION}/run_worker.sh" "${VERSION}/submit_worker_zzhang510.sh" "${VERSION}/dispatch_20ep_zzhang510.sh"
python3 -m py_compile "${VERSION}/validate_episode.py" "${VERSION}/aggregate_fixedseed20.py"
rg -F -q 'FIXED_SEED="${FIXED_SEED:-107}"' "${VERSION}/run_worker.sh"
rg -F -q '[[ "${FIXED_SEED}" == "107" ]]' "${VERSION}/run_worker.sh"
rg -F -q 'REPEATS="${REPEATS:-4}"' "${VERSION}/run_worker.sh"
rg -F -q 'NUM_TRIALS=1' "${VERSION}/run_worker.sh"
rg -F -q 'v127_single_seed107_serial_replay/run_one.sh' "${VERSION}/run_worker.sh"
rg -F -q 'for worker_id in 0 1 2 3 4' "${VERSION}/dispatch_20ep_zzhang510.sh"
rg -F -q 'FIXED_SEED=107' "${VERSION}/submit_worker_zzhang510.sh"
echo 'task21 v130 fixed-seed107 contract: PASS'
