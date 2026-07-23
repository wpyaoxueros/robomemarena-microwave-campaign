#!/usr/bin/env bash
set -euo pipefail

EVAL_PY="${1:?usage: $0 /path/to/evaluator.py}"
VERIFY_PYTHON="${ROBOMEMARENA_VERIFY_PYTHON:-python3}"

[[ -f "${EVAL_PY}" ]] || { echo "missing evaluator: ${EVAL_PY}" >&2; exit 2; }

"${VERIFY_PYTHON}" - "${EVAL_PY}" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1]).resolve()
pack_dir = path.parents[3]
for directory in (path.parent, pack_dir / "evaluators"):
    if str(directory) not in sys.path:
        sys.path.insert(0, str(directory))

from microwave_debug import microwave_joint_angle
from eef_direction_guard import evaluate_eef_direction_gate
from eef_release_guard import should_keep_place_gripper_closed
from forward_hold_guard import should_block_forward_until_hold, should_block_pick_forward
from runtime_hint import should_inject_hold_state_hint
from task22_stageprompt import load_pick_cookies_target, prompt_for_stage

required = (
    microwave_joint_angle,
    evaluate_eef_direction_gate,
    should_keep_place_gripper_closed,
    should_block_forward_until_hold,
    should_block_pick_forward,
    should_inject_hold_state_hint,
    load_pick_cookies_target,
    prompt_for_stage,
)
if not all(callable(item) for item in required):
    raise SystemExit("v22 evaluator dependency import is incomplete")
print("TASK22_STAGEPROMPT_OPENPICKCOOKIES_ROBOTANCHORS_EVALUATOR_DEPS_OK")
PY
