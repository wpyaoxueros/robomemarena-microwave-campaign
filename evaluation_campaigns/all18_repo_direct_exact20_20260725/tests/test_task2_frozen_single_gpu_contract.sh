#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_task2_frozen_single_gpu.sh"

test -x "${RUNNER}"
bash -n "${RUNNER}"
grep -F 'VLA_CUDA_VISIBLE_DEVICES=0' "${RUNNER}"
grep -F 'VLM_CUDA_VISIBLE_DEVICES=0' "${RUNNER}"
grep -F 'OFFICIAL_NUM_TRIALS=20' "${RUNNER}"
echo "PASS Task2 frozen one-GPU contract"
