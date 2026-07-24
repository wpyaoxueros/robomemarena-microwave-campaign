#!/usr/bin/env bash
set -euo pipefail

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${CAMPAIGN_DIR}/scripts/run_task21_d9_direct20_single_gpu.sh"

[[ -f "${RUNNER}" ]] || { echo "missing Task21 d9 runner: ${RUNNER}" >&2; exit 1; }
bash -n "${RUNNER}"

grep -Fq 'TASK21_PACK="${REPO_DIR}/tasks/task21"' "${RUNNER}"
grep -Fq 'materialize_microwave_d9_overlay.py' "${RUNNER}"
grep -Fq 'run_worker.sh' "${RUNNER}"
grep -Fq 'aggregate_fixedseed20.py' "${RUNNER}"
grep -Fq 'for worker_id in 0 1 2 3 4; do' "${RUNNER}"
grep -Fq 'CUDA_VISIBLE_DEVICES=0' "${RUNNER}"
grep -Fq 'VLA_CUDA_VISIBLE_DEVICES=0' "${RUNNER}"
grep -Fq 'VLM_CUDA_VISIBLE_DEVICES=0' "${RUNNER}"
grep -Fq 'd9f83ac5182e25ad7f0a301a77a0b667f2392df1' "${RUNNER}"
! grep -Fq '62214036103ee8d5fef9b475dd8b344b6e2cfc03' "${RUNNER}"

echo "PASS Task21 d9 single-GPU direct20 contract"
