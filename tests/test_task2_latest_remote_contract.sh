#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_task2_original_exact_single_gpu_shard.sh"

test -x "${RUNNER}"
bash -n "${RUNNER}"
grep -F 'RoboMemArena_openhelix_d9f83ac_20260725' "${RUNNER}"
grep -F 'EXPECTED_REMOTE_COMMIT=d9f83ac5182e25ad7f0a301a77a0b667f2392df1' "${RUNNER}"
grep -F 'task2_26_reference_stage.py' "${RUNNER}"
grep -F 'EXPECTED_TASK2_BDDL_SHA256=df9035b23260d3f664f0852e155e2bc3e469897f7999792c365c949a9df244b7' "${RUNNER}"
grep -F 'TASKS2_26_LATEST_REMOTE_INTERFACE=1' "${RUNNER}"
grep -F 'adapters/task2_d9latest_officialscore.py' "${RUNNER}"
grep -F 'task2_26_reference_stage.py' \
  "${ROOT}/adapters/task2_d9latest_officialscore.py"
if grep -Fq 'rma_refeval_fresh_20260513_052445' "${RUNNER}"; then
  echo "stale Task2 remote checkout remains in launcher" >&2
  exit 1
fi
echo "PASS Task2 d9f83ac latest-remote contract"
