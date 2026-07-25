#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${ROOT}/scripts/run_archived_original_snapshot_topology.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

FROZEN_SNAPSHOT_DRY_RUN=1 \
OUTPUT_ROOT="${tmp}/output" \
CAMPAIGN_GIT_COMMIT=test-contract \
bash "${RUNNER}" 2 >/dev/null

plan="${tmp}/output/archived_original_snapshot/task2_originalsnapshot66e789_exact20_dryrun/original_snapshot_runtime_plan.env"
[[ -f "${plan}" ]]
grep -Fx 'task_id=2' "${plan}"
grep -Fx 'num_trials=20' "${plan}"
grep -Fx 'seed=104' "${plan}"
grep -Fx 'max_steps=2000' "${plan}"
grep -Fx 'replan_steps=5' "${plan}"
grep -Fx 'passage_counts=__NONE__' "${plan}"
grep -Fx 'drawer_forward_advance_guard=0' "${plan}"
grep -Fx 'pick_gripper_gate=0' "${plan}"
grep -Fx 'pick_lift_gate=0' "${plan}"
grep -Fx 'vlm_task_text_mode=english_reference_no_candidate' "${plan}"
grep -Fx 'completed_subtasks_mode=off' "${plan}"
grep -Fx 'frozen_launcher_sha256=11aba57fac364c8e9fc9f430c44edf7677defcdd00982667b75e07f98cc9cebd' "${plan}"
grep -Fx 'frozen_evaluator_sha256=cda4a23bf018f0c9e4ecb8bc6438d08fbfc6c7be92ebe655751604833dfe3ed4' "${plan}"

FROZEN_SNAPSHOT_DRY_RUN=1 \
OUTPUT_ROOT="${tmp}/output" \
CAMPAIGN_GIT_COMMIT=test-contract \
bash "${RUNNER}" 12 >/dev/null

task12_plan="${tmp}/output/archived_original_snapshot/task12_originalsnapshot66e789_exact20_dryrun/original_snapshot_runtime_plan.env"
task12_passages="${tmp}/output/archived_original_snapshot/task12_originalsnapshot66e789_exact20_dryrun/execution_pack/repro_snapshot/files/passage_counts__drawer_passage_counts_task4full_plus_alltasks_20260627.json"
[[ -f "${task12_plan}" ]]
[[ -f "${task12_passages}" ]]
grep -Fx "passage_counts=${task12_passages}" "${task12_plan}"

echo 'PASS archived original snapshot topology contract'
