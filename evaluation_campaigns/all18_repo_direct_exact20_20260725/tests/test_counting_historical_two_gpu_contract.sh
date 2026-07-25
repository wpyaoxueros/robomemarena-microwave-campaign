#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_counting_historical_two_gpu.sh"
SUBMITTER="${ROOT}/scripts/submit_counting_historical_two_gpu.sh"

test -x "${RUNNER}"
test -x "${SUBMITTER}"

grep -Fq 'TASK_ID=${1:?usage: run_counting_historical_two_gpu.sh TASK_ID}' "${RUNNER}"
grep -Fq 'historical counting comparator requires exactly two visible GPUs' "${RUNNER}"
grep -Fq 'counting/task6_fixed_seed_latest_d9f83ac' "${RUNNER}"
grep -Fq 'counting/task16_vlm35999_d9f83ac_pourreturnassist_20260724' "${RUNNER}"
grep -Fq 'run_task6_fixed_seed_repeat_worker.sh' "${RUNNER}"
grep -Fq 'run_task16_29ep.sh' "${RUNNER}"
grep -Fq 'vla_cuda_visible_devices=0' "${RUNNER}"
grep -Fq 'vlm_eval_cuda_visible_devices=1' "${RUNNER}"
grep -Fq -- '--gres=gpu:2' "${SUBMITTER}"
! grep -Fq 'single_gpu' "${RUNNER}"
! grep -Fq 'build_counting_single_gpu_overlay.py' "${RUNNER}"
! grep -Fq 'materialize_counting_evaluator_overlay.py' "${RUNNER}"

echo 'PASS: counting historical two-GPU contract'
