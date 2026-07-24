#!/usr/bin/env python3
"""Ensure the Task1 frozen runner receives the Task1 target schema."""

from __future__ import annotations

import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
CAMPAIGN_ROOT = ROOT.parent
RUNNER = (
    CAMPAIGN_ROOT
    / "latest_openhelix_d9f83ac_exact20_20260725"
    / "scripts"
    / "run_archived_task_exact20.sh"
)
TASK1_TARGETS = pathlib.Path(
    "/data/user/hlei573/openpi_inference/task1_eval/"
    "task1_subtask_end_poses_successindex_seed100_199.json"
)


def main() -> int:
    text = RUNNER.read_text(encoding="utf-8")
    assert 'ENDPOSE_HOLD_TARGETS_JSON="${TASK1_TARGETS_JSON}"' in text

    payload = json.loads(TASK1_TARGETS.read_text(encoding="utf-8"))
    subtasks = payload["subtasks"]
    assert subtasks
    assert all(isinstance(target, dict) for target in subtasks.values())
    assert all(
        any(key in target for key in ("target_ee_pos", "ee_pos", "median_ee_pos"))
        for target in subtasks.values()
    )
    print("PASS Task1 archived end-pose target contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
