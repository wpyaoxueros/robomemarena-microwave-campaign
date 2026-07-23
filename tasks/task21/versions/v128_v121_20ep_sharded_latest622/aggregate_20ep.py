#!/usr/bin/env python3
"""Aggregate five Task21 V128 four-episode shards with strict seed validation."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path


EXPECTED_SEEDS = list(range(100, 120))


def read_rows(run_root: Path) -> list[dict[str, str]]:
    source = run_root / "official_episodes.tsv"
    if not source.is_file():
        raise FileNotFoundError(f"missing {source}")
    with source.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle, delimiter="\t"))
    if len(rows) != 4:
        raise ValueError(f"{source} must contain exactly 4 episodes, got {len(rows)}")
    for row in rows:
        if row.get("task_id") != "21":
            raise ValueError(f"{source} contains non-Task21 row: {row}")
        row["run_root"] = str(run_root)
    return rows


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("run_roots", nargs=5, type=Path)
    args = parser.parse_args()

    rows = [row for root in args.run_roots for row in read_rows(root)]
    rows.sort(key=lambda row: int(row["seed"]))
    seeds = [int(row["seed"]) for row in rows]
    if seeds != EXPECTED_SEEDS:
        raise ValueError(f"expected seeds {EXPECTED_SEEDS}, got {seeds}")

    stage_successes = sum(row["stage_success"] == "Y" for row in rows)
    goal_successes = sum(row["goal_success"] == "Y" for row in rows)
    average_score = sum(float(row["score_pct"]) for row in rows) / len(rows)
    summary = {
        "task_id": 21,
        "episodes": len(rows),
        "seed_min": min(seeds),
        "seed_max": max(seeds),
        "stage_successes": stage_successes,
        "stage_success_rate": stage_successes / len(rows),
        "goal_successes": goal_successes,
        "goal_success_rate": goal_successes / len(rows),
        "average_stage_score_pct": average_score,
        "run_roots": [str(root) for root in args.run_roots],
    }
    args.output_dir.mkdir(parents=True, exist_ok=True)
    with (args.output_dir / "episodes.tsv").open("w", encoding="utf-8", newline="") as handle:
        fields = [*rows[0].keys()]
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)
    (args.output_dir / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    (args.output_dir / "summary.tsv").write_text(
        "task_id\tepisodes\tseed_range\tstage_successes\tstage_success_rate\tgoal_successes\tgoal_success_rate\taverage_stage_score_pct\n"
        f"21\t{len(rows)}\t100-119\t{stage_successes}\t{stage_successes / len(rows):.4f}\t{goal_successes}\t{goal_successes / len(rows):.4f}\t{average_score:.4f}\n",
        encoding="utf-8",
    )
    print(json.dumps(summary, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
