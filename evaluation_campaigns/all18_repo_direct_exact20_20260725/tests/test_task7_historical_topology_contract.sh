#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_task7_historical_topology_8ep.sh"
SUBMITTER="${ROOT}/scripts/submit_task7_historical_topology_8ep.sh"

[[ -x "${RUNNER}" ]]
[[ -x "${SUBMITTER}" ]]

grep -Fq 'task7_vlm35999_latest_d9f83ac_hardcase500_20260724' "${RUNNER}"
grep -Fq 'exec bash "${FROZEN_RUNNER}"' "${RUNNER}"
grep -Fq 'official_source_archives/RoboMemArena_openhelix_d9f83ac_full_20260725/evaluation_benchmark/libero_fork' "${RUNNER}"
grep -Fq 'GIT_CONFIG_KEY_0=safe.directory' "${RUNNER}"
grep -Fq 'GIT_CONFIG_KEY_1=safe.directory' "${RUNNER}"
grep -Fq 'd9f83ac5182e25ad7f0a301a77a0b667f2392df1' "${RUNNER}"
grep -Fq 'CUDA_VISIBLE_DEVICES=0' "${RUNNER}"
grep -Fq 'CUDA_VISIBLE_DEVICES=1' "${RUNNER}"
grep -Fq 'MUJOCO_EGL_DEVICE_ID=1' "${RUNNER}"
grep -Fq 'NUM_TRIALS=8' "${RUNNER}"
grep -Fq 'SEED=100' "${RUNNER}"
grep -Fq 'REPLAN_STEPS=5' "${RUNNER}"
grep -Fq 'POST_STAGE_STEPS=30' "${RUNNER}"
grep -Fq 'VLM_INTERVAL=25' "${RUNNER}"
grep -Fq 'HOLD_AFTER_REQUIRED_STAGES=0' "${RUNNER}"
! grep -Fq 'build_counting_single_gpu_overlay.py' "${RUNNER}"
! grep -Fq 'materialize_counting_evaluator_overlay.py' "${RUNNER}"

grep -Fq -- '--gres=gpu:2' "${SUBMITTER}"
! grep -Fq -- '--gres=gpu:1' "${SUBMITTER}"
grep -Fq 'tmux -f /dev/null new-session' "${SUBMITTER}"
grep -Fq 'run_task7_historical_topology_8ep.sh' "${SUBMITTER}"

echo 'PASS Task7 historical two-GPU topology contract'
