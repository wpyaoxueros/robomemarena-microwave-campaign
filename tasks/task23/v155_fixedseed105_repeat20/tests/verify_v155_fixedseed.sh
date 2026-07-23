#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "${ROOT}/tests/verify_v154_config.sh"
rg -q 'for repeat in 0 1 2 3' "${ROOT}/scripts/run_fixed_seed_worker.sh"
rg -q 'NUM_TRIALS=1' "${ROOT}/scripts/run_fixed_seed_worker.sh"
rg -q 'SEED="\$\{FIXED_SEED\}"' "${ROOT}/scripts/run_fixed_seed_worker.sh"
rg -q 'FIXED_SEED="\$\{FIXED_SEED:-105\}"' "${ROOT}/scripts/run_fixed_seed_worker.sh"
rg -q 'WORKER_ID must be 0..4' "${ROOT}/submit_fixedseed105_zzhang510.sh"
rg -q -- '--gres=gpu:2' "${ROOT}/submit_fixedseed105_zzhang510.sh"

echo 'PASS: v155 schedules twenty independent one-episode seed105 rollouts without changing v154 evaluation behavior'
