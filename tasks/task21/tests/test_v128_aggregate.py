#!/usr/bin/env python3
"""Contract test for the Task21 V128 20-episode aggregator."""

from __future__ import annotations

import csv
import json
import subprocess
import sys
import tempfile
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
SCRIPT = REPO / "versions" / "v128_v121_20ep_sharded_latest622" / "aggregate_20ep.py"


def write_shard(root: Path, start_seed: int) -> None:
    root.mkdir(parents=True)
    with (root / "official_episodes.tsv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["task_id", "ep", "seed", "score_pct", "tsr_success", "stage_success", "goal_success", "log"],
            delimiter="\t",
        )
        writer.writeheader()
        for ep in range(4):
            seed = start_seed + ep
            writer.writerow(
                {
                    "task_id": "21",
                    "ep": str(ep),
                    "seed": str(seed),
                    "score_pct": "100.0" if seed % 2 == 0 else "66.7",
                    "tsr_success": "Y" if seed % 2 == 0 else "N",
                    "stage_success": "Y" if seed % 2 == 0 else "N",
                    "goal_success": "Y" if seed % 2 == 0 else "N",
                    "log": f"/tmp/seed{seed}.log",
                }
            )


def main() -> None:
    assert SCRIPT.is_file(), f"missing {SCRIPT}"
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        run_roots = []
        for start in (100, 104, 108, 112, 116):
            shard = root / f"shard_{start}"
            write_shard(shard, start)
            run_roots.append(str(shard))
        output = root / "aggregate"
        subprocess.run([sys.executable, str(SCRIPT), "--output-dir", str(output), *run_roots], check=True)
        summary = json.loads((output / "summary.json").read_text(encoding="utf-8"))
        assert summary["episodes"] == 20
        assert summary["seed_min"] == 100
        assert summary["seed_max"] == 119
        assert summary["stage_successes"] == 10
        assert summary["stage_success_rate"] == 0.5
    print("task21 v128 aggregate: PASS")


if __name__ == "__main__":
    main()
