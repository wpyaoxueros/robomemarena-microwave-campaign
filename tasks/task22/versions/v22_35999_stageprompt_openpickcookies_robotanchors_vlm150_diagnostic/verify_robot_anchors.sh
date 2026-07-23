#!/usr/bin/env bash
set -euo pipefail

ANCHOR_JSON="${1:?usage: $0 /path/to/initial-anchor.json}"
VERIFY_PYTHON="${ROBOMEMARENA_VERIFY_PYTHON:?set ROBOMEMARENA_VERIFY_PYTHON to the rollout interpreter}"

[[ -r "${ANCHOR_JSON}" ]] || { echo "missing anchor config: ${ANCHOR_JSON}" >&2; exit 2; }

"${VERIFY_PYTHON}" - "${ANCHOR_JSON}" <<'PY'
import json
import math
import sys
from pathlib import Path

import h5py

path = Path(sys.argv[1])
payload = json.loads(path.read_text())
metadata = payload.get("metadata", {})
if metadata.get("object_anchor") is not False:
    raise SystemExit("v22 anchor must explicitly disable object_anchor")
if metadata.get("robot_only") is not True:
    raise SystemExit("v22 anchor must explicitly declare robot_only")
rules = payload.get("tasks", {}).get("22")
if not isinstance(rules, list) or len(rules) != 2:
    raise SystemExit("v22 requires exactly two Task22 initial-anchor rules")

expected_rules = (
    ("open microwave", "open_microwave_4_seed104_task22.hdf5"),
    ("pick cookies", "pick_cookies_5_seed104_task22.hdf5"),
)
expected = {"joint_states": 7, "gripper_states": 2, "ee_pos": 3}
for rule, (expected_subtask, expected_basename) in zip(rules, expected_rules, strict=True):
    if rule.get("subtask") != expected_subtask or int(rule.get("frame_idx", -1)) != 0:
        raise SystemExit(f"v22 anchor must be frame 0 for {expected_subtask}")
    hdf_path = Path(rule.get("anchor_hdf5", ""))
    if hdf_path.name != expected_basename:
        raise SystemExit(f"unexpected HDF for {expected_subtask}: {hdf_path}")
    if not hdf_path.is_file():
        raise SystemExit(f"missing anchor HDF: {hdf_path}")
    with h5py.File(hdf_path, "r") as handle:
        values = {
            "joint_states": handle["/data/demo_0/obs/joint_states"][0],
            "gripper_states": handle["/data/demo_0/obs/gripper_states"][0],
            "ee_pos": handle["/data/demo_0/obs/ee_pos"][0],
        }
    for name, value in values.items():
        flat = [float(item) for item in value.reshape(-1)]
        if len(flat) != expected[name] or not all(math.isfinite(item) for item in flat):
            raise SystemExit(f"invalid {name} in {hdf_path}")
print("TASK22_V22_ROBOT_ANCHORS_OK")
PY
