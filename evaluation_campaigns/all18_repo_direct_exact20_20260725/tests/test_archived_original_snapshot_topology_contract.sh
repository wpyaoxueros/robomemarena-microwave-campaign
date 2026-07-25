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
grep -Fx 'frozen_evaluator_sha256=ef95604ca17c7900eac172d0e082a3738ca5b62e8468bf4f53c522590ff7dd2b' "${plan}"
grep -Fx 'original_runtime_evaluator_sha256=ef95604ca17c7900eac172d0e082a3738ca5b62e8468bf4f53c522590ff7dd2b' "${plan}"

FROZEN_SNAPSHOT_DRY_RUN=1 \
OUTPUT_ROOT="${tmp}/output" \
CAMPAIGN_GIT_COMMIT=test-contract \
bash "${RUNNER}" 12 >/dev/null

task12_plan="${tmp}/output/archived_original_snapshot/task12_originalsnapshot66e789_exact20_dryrun/original_snapshot_runtime_plan.env"
task12_passages="${tmp}/output/archived_original_snapshot/task12_originalsnapshot66e789_exact20_dryrun/execution_pack/repro_snapshot/files/passage_counts__drawer_passage_counts_task4full_plus_alltasks_20260627.json"
[[ -f "${task12_plan}" ]]
[[ -f "${task12_passages}" ]]
grep -Fx "passage_counts=${task12_passages}" "${task12_plan}"

FROZEN_SNAPSHOT_DRY_RUN=1 \
OUTPUT_ROOT="${tmp}/output" \
CAMPAIGN_GIT_COMMIT=test-contract \
bash "${RUNNER}" 18 >/dev/null

task18_plan="${tmp}/output/archived_original_snapshot/task18_originalsnapshot66e789_exact20_dryrun/original_snapshot_runtime_plan.env"
[[ -f "${task18_plan}" ]]
grep -Fx 'task_id=18' "${task18_plan}"
grep -Fx 'replan_steps=5' "${task18_plan}"
grep -Fx 'pick_gripper_gate=0' "${task18_plan}"
grep -Fx 'pick_lift_gate=0' "${task18_plan}"
grep -Fx 'completed_subtasks_mode=off' "${task18_plan}"

echo 'PASS archived original snapshot topology contract'
