#!/usr/bin/env python3
"""Strictly aggregate the five-worker Task21 V130 fixed-seed test."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path


EXPECTED_WORKERS = list(range(5))
EXPECTED_EPISODES = list(range(20))
FIXED_SEED = 107


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch-root", required=True, type=Path)
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()
    batch_root = args.batch_root.resolve()
    output_dir = (args.output_dir or batch_root / "aggregate").resolve()

    rows: list[dict[str, str]] = []
    errors: list[str] = []
    for worker_id in EXPECTED_WORKERS:
        worker_root = batch_root / f"worker{worker_id}"
        attempts_path = worker_root / "attempts.tsv"
        if not (worker_root / "COMPLETE").is_file():
            errors.append(f"worker{worker_id}:missing_COMPLETE")
        if not attempts_path.is_file():
            errors.append(f"worker{worker_id}:missing_attempts")
            continue
        worker_rows = read_rows(attempts_path)
        if len(worker_rows) != 4:
            errors.append(f"worker{worker_id}:attempt_rows={len(worker_rows)}")
        for row in worker_rows:
            if row.get("worker_id") != str(worker_id):
                errors.append(f"worker{worker_id}:bad_worker_id={row.get('worker_id')}")
            if row.get("seed") != str(FIXED_SEED):
                errors.append(f"worker{worker_id}:bad_seed={row.get('seed')}")
            if row.get("validation_valid") != "1":
                errors.append(f"worker{worker_id}:invalid_episode={row.get('global_episode')}")
            rows.append(row)

    rows.sort(key=lambda row: int(row["global_episode"]))
    episodes = [int(row["global_episode"]) for row in rows]
    if episodes != EXPECTED_EPISODES:
        errors.append(f"global_episodes={episodes}")

    output_dir.mkdir(parents=True, exist_ok=True)
    fields = [
        "global_episode",
        "worker_id",
        "repeat",
        "seed",
        "run_id",
        "exit_code",
        "validation_valid",
        "stage_score_pct",
        "stage_success",
        "goal_success",
        "run_dir",
    ]
    with (output_dir / "episodes.tsv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)

    valid_rows = [row for row in rows if row.get("validation_valid") == "1"]
    stage_successes = sum(row.get("stage_success") == "Y" for row in valid_rows)
    goal_successes = sum(row.get("goal_success") == "Y" for row in valid_rows)
    average_score = (
        sum(float(row["stage_score_pct"]) for row in valid_rows) / len(valid_rows)
        if valid_rows
        else 0.0
    )
    summary = {
        "task_id": 21,
        "measurement": "fixed_seed_repeatability",
        "fixed_seed": FIXED_SEED,
        "requested_episodes": 20,
        "valid_episodes": len(valid_rows),
        "stage_successes": stage_successes,
        "stage_success_rate": stage_successes / len(valid_rows) if valid_rows else 0.0,
        "goal_successes": goal_successes,
        "goal_success_rate": goal_successes / len(valid_rows) if valid_rows else 0.0,
        "average_stage_score_pct": average_score,
        "errors": errors,
    }
    (output_dir / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    (output_dir / "summary.tsv").write_text(
        "task_id\tmeasurement\tfixed_seed\trequested_episodes\tvalid_episodes\tstage_successes\tstage_success_rate\tgoal_successes\tgoal_success_rate\taverage_stage_score_pct\terrors\n"
        f"21\tfixed_seed_repeatability\t{FIXED_SEED}\t20\t{len(valid_rows)}\t{stage_successes}\t"
        f"{summary['stage_success_rate']:.4f}\t{goal_successes}\t{summary['goal_success_rate']:.4f}\t"
        f"{average_score:.4f}\t{';'.join(errors)}\n",
        encoding="utf-8",
    )
    print(json.dumps(summary, sort_keys=True))
    return 0 if not errors and len(valid_rows) == 20 else 1


if __name__ == "__main__":
    raise SystemExit(main())
