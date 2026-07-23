#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import statistics
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from validate_episode import validate_run  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("batch_root", type=Path)
    args = parser.parse_args()
    batch_root = args.batch_root.resolve()

    records: list[dict[str, object]] = []
    for worker in range(5):
        worker_root = batch_root / f"worker{worker}"
        if not (worker_root / "COMPLETE").is_file():
            raise SystemExit(f"worker {worker} is incomplete")
        for valid_path in sorted(worker_root.glob("episode*/valid_run.txt")):
            episode = int(valid_path.parent.name.removeprefix("episode"))
            run_dir = Path(valid_path.read_text().strip())
            record = validate_run(run_dir)
            record.update({"worker": worker, "episode": episode, "seed": 106})
            records.append(record)

    records.sort(key=lambda item: int(item["episode"]))
    episodes = [int(item["episode"]) for item in records]
    seeds = [int(item["seed"]) for item in records]
    if episodes != list(range(20)):
        raise SystemExit(f"expected episodes 0..19 exactly once, found {episodes}")
    if seeds != [106] * 20:
        raise SystemExit(f"expected fixed seed106 for all episodes, found {seeds}")

    episodes_path = batch_root / "episodes.tsv"
    fields = (
        "worker",
        "episode",
        "seed",
        "stage_score_pct",
        "stage_success_rate",
        "goal_success_rate",
        "video",
        "run_dir",
    )
    with episodes_path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        for record in records:
            writer.writerow({field: record[field] for field in fields})

    successes = sum(float(item["stage_success_rate"]) == 1.0 for item in records)
    goal_successes = sum(float(item["goal_success_rate"]) == 1.0 for item in records)
    result = {
        "episodes": len(records),
        "stage_successes": successes,
        "stage_success_rate": successes / len(records),
        "goal_successes": goal_successes,
        "goal_success_rate": goal_successes / len(records),
        "average_stage_score_pct": statistics.fmean(
            float(item["stage_score_pct"]) for item in records
        ),
        "fixed_seed": 106,
        "episode_min": min(episodes),
        "episode_max": max(episodes),
    }
    (batch_root / "summary_20ep.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
