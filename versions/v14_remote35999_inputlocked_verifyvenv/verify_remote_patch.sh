#!/usr/bin/env bash
set -euo pipefail

: "${ROBOMEMARENA_REMOTE_ROOT:?set ROBOMEMARENA_REMOTE_ROOT to the repaired remote checkout}"
EXPECTED_REMOTE_COMMIT=8b7710924f862ab1c8dea69adada62e8c462de40
VERIFY_PYTHON="${ROBOMEMARENA_VERIFY_PYTHON:-python3}"
[[ -x "${VERIFY_PYTHON}" || "${VERIFY_PYTHON}" == "python3" ]] || {
  echo "remote verifier interpreter is unavailable" >&2
  exit 2
}

actual_commit="$(git -C "${ROBOMEMARENA_REMOTE_ROOT}" rev-parse HEAD)"
[[ "${actual_commit}" == "${EXPECTED_REMOTE_COMMIT}" ]] || {
  echo "remote commit mismatch: expected=${EXPECTED_REMOTE_COMMIT} actual=${actual_commit}" >&2
  exit 2
}
git -C "${ROBOMEMARENA_REMOTE_ROOT}" diff --quiet || {
  echo "remote checkout is dirty" >&2
  exit 2
}

"${VERIFY_PYTHON}" - <<PY
import sys
from pathlib import Path

root = Path("${ROBOMEMARENA_REMOTE_ROOT}")
sys.path.insert(0, str(root / "evaluation_benchmark" / "scripts"))
import task2_26_reference_stage as stages

names = [spec.name for spec in stages._task_specs(22)]
expected = [
    "01_Lift_Tomato_Sauce",
    "02_Pour_One",
    "03_Pour_Two",
    "04_Place_Tomato_Aside",
    "05_Open_Microwave",
    "06_Place_Cookies_Microwave",
    "07_Close_Microwave",
]
if names != expected:
    raise SystemExit(f"Task22 stage mismatch: {names!r}")
stage_done = {name: True for name in names}
stage_done["07_Close_Microwave"] = False
if not stages._stage_success_from_stage_done(22, stage_done):
    raise SystemExit("Task22 optional-close success contract failed")
stage_done["05_Open_Microwave"] = False
if stages._stage_success_from_stage_done(22, stage_done):
    raise SystemExit("Task22 open-microwave stage is not required")
print("TASK22_REMOTE_PATCH_CONTRACT_OK")
PY
