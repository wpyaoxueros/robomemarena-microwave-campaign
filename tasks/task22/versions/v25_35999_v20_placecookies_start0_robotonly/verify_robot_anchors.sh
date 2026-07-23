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
    raise SystemExit("v25 anchor must explicitly disable object_anchor")
if metadata.get("robot_only") is not True:
    raise SystemExit("v25 anchor must explicitly declare robot_only")
rules = payload.get("tasks", {}).get("22")
if not isinstance(rules, list) or len(rules) != 3:
    raise SystemExit("v25 requires exactly three Task22 initial-anchor rules")

expected_rules = (
    ("open microwave", "open_microwave_4_seed104_task22.hdf5", 0),
    ("pick cookies", "pick_cookies_5_seed104_task22.hdf5", 160),
    ("place cookies", "place_cookies_6_seed104_task22.hdf5", 0),
)
expected = {"joint_states": 7, "gripper_states": 2, "ee_pos": 3}
for rule, (expected_subtask, expected_basename, expected_frame) in zip(rules, expected_rules, strict=True):
    if rule.get("subtask") != expected_subtask or int(rule.get("frame_idx", -1)) != expected_frame:
            raise SystemExit(f"v25 anchor must be frame {expected_frame} for {expected_subtask}")
    hdf_path = Path(rule.get("anchor_hdf5", ""))
    if hdf_path.name != expected_basename:
        raise SystemExit(f"unexpected HDF for {expected_subtask}: {hdf_path}")
    if not hdf_path.is_file():
        raise SystemExit(f"missing anchor HDF: {hdf_path}")
    with h5py.File(hdf_path, "r") as handle:
        values = {
            "joint_states": handle["/data/demo_0/obs/joint_states"][expected_frame],
            "gripper_states": handle["/data/demo_0/obs/gripper_states"][expected_frame],
            "ee_pos": handle["/data/demo_0/obs/ee_pos"][expected_frame],
        }
        if expected_subtask == "pick cookies":
            action_gripper = float(handle["/data/demo_0/actions"][expected_frame, 6])
            if action_gripper >= 0.0:
                raise SystemExit("v25 pick-cookies anchor must remain before gripper closing")
        if expected_subtask == "place cookies":
            action_gripper = float(handle["/data/demo_0/actions"][expected_frame, 6])
            if action_gripper <= 0.0:
                raise SystemExit("v25 place-cookies anchor must begin before release")
    for name, value in values.items():
        flat = [float(item) for item in value.reshape(-1)]
        if len(flat) != expected[name] or not all(math.isfinite(item) for item in flat):
            raise SystemExit(f"invalid {name} in {hdf_path}")
print("TASK22_V25_ROBOT_ANCHORS_OK")
PY
