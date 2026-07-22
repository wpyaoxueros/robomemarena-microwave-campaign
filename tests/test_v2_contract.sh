#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${REPO}/scripts/run_task22_v2_vlm_eef_pour_latest622.sh"
ANCHORS="${REPO}/config/release_anchors_t22_v2_robotonly.json"

bash -n "${RUNNER}"
bash -n "${REPO}/versions/v2_vlm_eef_pour_forwardguard/run_one.sh"
bash -n "${REPO}/versions/v2_vlm_eef_pour_forwardguard/submit_one_zzhang510.sh"
bash -n "${REPO}/versions/v2_vlm_eef_pour_forwardguard/dispatch_after_probe_zzhang510.sh"
rg -q 'ORACLE_HOLD_RELEASE_NEXT=0' "${RUNNER}"
rg -q 'ORACLE_STAGE_ADVANCE_NEXT=0' "${RUNNER}"
rg -q 'VLM_COMPLETED_SUBTASKS_MODE=off' "${RUNNER}"
rg -q 'REQUIRE_HOLD_RELEASE_FOR_FORWARD=1' "${RUNNER}"
rg -q 'REQUIRE_HOLD_RELEASE_FOR_FORWARD_SUBTASKS="pick tomato,pour first"' "${RUNNER}"
rg -q 'object_anchor.: false' "${ANCHORS}"
rg -q 'stage_prompt_override.: false' "${ANCHORS}"
rg -q '</dev/null' "${REPO}/versions/v2_vlm_eef_pour_forwardguard/dispatch_after_probe_zzhang510.sh"
if rg -q 'STAGE_PROMPT_OVERRIDE|ORACLE_.*=1|object_mw' "${RUNNER}" "${ANCHORS}"; then
  echo "v2 must not use forced prompts or object anchors" >&2
  exit 1
fi
PYTHONPATH="${REPO}/evaluators" python3 - <<'PY'
from forward_hold_guard import should_block_forward_until_hold

assert should_block_forward_until_hold(
    enabled=True,
    hold_active=False,
    current_subtask="pour first",
    next_subtask="pour second",
    current_index=1,
    next_index=2,
    selected_subtasks={"pour first"},
    hold_started_before=False,
)
assert not should_block_forward_until_hold(
    enabled=True,
    hold_active=False,
    current_subtask="pour first",
    next_subtask="pour second",
    current_index=1,
    next_index=2,
    selected_subtasks={"pour first"},
    hold_started_before=True,
)
PY
