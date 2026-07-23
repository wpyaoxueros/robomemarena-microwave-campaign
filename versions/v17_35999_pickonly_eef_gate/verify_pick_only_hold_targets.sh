#!/usr/bin/env bash
set -euo pipefail

TARGET_JSON="${1:?usage: $0 /path/to/task22_pick_tomato_only_endpose_targets.json}"
VERIFY_PYTHON="${ROBOMEMARENA_VERIFY_PYTHON:-python3}"

"${VERIFY_PYTHON}" - "${TARGET_JSON}" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
payload = json.loads(path.read_text(encoding="utf-8"))
subtasks = payload["tasks"]["22"]["subtasks"]
if set(subtasks) != {"pick tomato"}:
    raise SystemExit(f"unexpected Task22 hold targets: {sorted(subtasks)}")
target = subtasks["pick tomato"]
if len(target["target_ee_pos"]) != 3 or target.get("hold_gripper") != 1:
    raise SystemExit("invalid pick-tomato hold target")
print("TASK22_PICK_ONLY_HOLD_TARGET_OK")
PY
