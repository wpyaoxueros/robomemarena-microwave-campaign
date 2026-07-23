#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_JSON="${1:?usage: $0 /path/to/tasks2_26_endpose_targets_seed100_199.json}"
VERIFY_PYTHON="${ROBOMEMARENA_VERIFY_PYTHON:-python3}"

"${VERIFY_PYTHON}" "${VERSION_DIR}/tests/test_task22_stageprompt.py"
"${VERIFY_PYTHON}" - "${TARGET_JSON}" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
target = payload["tasks"]["22"]["subtasks"]["pick cookies"]
if len(target["target_ee_pos"]) != 3 or float(target.get("hold_gripper", -1.0)) != 1.0:
    raise SystemExit("invalid Task22 pick-cookies diagnostic target")
print("TASK22_STAGEPROMPT_TARGET_OK")
PY
