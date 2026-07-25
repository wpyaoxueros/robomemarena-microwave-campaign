#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_task7_fixed_seed_repeat_worker.sh"

bash -n "${RUNNER}"
grep -Fq 'NUM_TRIALS=1' "${RUNNER}"
grep -Fq 'SEED="${FIXED_SEED}"' "${RUNNER}"
grep -Fq 'VLA_POLICY_SEED="${FIXED_SEED}"' "${RUNNER}"
grep -Fq 'oracle_prompt_injection=off' "${RUNNER}"
grep -Fq 'EXPECTED_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1' "${RUNNER}"
echo 'task7 fixed-seed worker contract: PASS'
