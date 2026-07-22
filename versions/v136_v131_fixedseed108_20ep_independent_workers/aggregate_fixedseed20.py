#!/usr/bin/env python3
"""Aggregate the 20 independent fixed-seed Task24 v136 attempts."""

from __future__ import annotations

import csv
import json
import sys
from pathlib import Path


def rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: aggregate_fixedseed20.py <batch-root>", file=sys.stderr)
        return 2

    batch_root = Path(sys.argv[1]).resolve()
    attempts: list[dict[str, str]] = []
    missing_workers: list[int] = []
    for worker_id in range(5):
        attempt_path = batch_root / f"worker{worker_id}" / "attempts.tsv"
        if not attempt_path.is_file():
            missing_workers.append(worker_id)
            continue
        attempts.extend(rows(attempt_path))

    valid = [row for row in attempts if row.get("validation_valid") == "1"]
    stage_successes = sum(row.get("stage_success") == "Y" for row in valid)
    goal_successes = sum(row.get("goal_success") == "Y" for row in valid)
    scores = [float(row["stage_score_pct"]) for row in valid if row.get("stage_score_pct")]
    payload = {
        "expected_attempts": 20,
        "attempt_rows": len(attempts),
        "valid_attempts": len(valid),
        "missing_workers": missing_workers,
        "fixed_seed_values": sorted({row.get("seed") for row in attempts}),
        "stage_successes": stage_successes,
        "goal_successes": goal_successes,
        "stage_success_rate_pct": 100.0 * stage_successes / len(valid) if valid else 0.0,
        "goal_success_rate_pct": 100.0 * goal_successes / len(valid) if valid else 0.0,
        "average_stage_score_pct": sum(scores) / len(scores) if scores else 0.0,
        "complete": len(attempts) == 20 and len(valid) == 20 and not missing_workers,
    }
    print(json.dumps(payload, sort_keys=True))
    return 0 if payload["complete"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
