#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_counting_direct20_single_gpu.sh"
LIBERO_ROOT=/data/user/hlei573/vla_memory_experiments/official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork

test -d "${LIBERO_ROOT}"
grep -F "TARGET_LIBERO_PATH=${LIBERO_ROOT}" "${RUNNER}"
grep -F 'materialize_counting_evaluator_overlay.py' "${RUNNER}"
grep -F 'EVALUATOR_OVERLAY_ROOT' "${RUNNER}"
bash -n "${RUNNER}"
echo "PASS counting direct20 LIBERO-root contract"
