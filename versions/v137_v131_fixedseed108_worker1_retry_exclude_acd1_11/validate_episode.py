#!/usr/bin/env python3
"""Validate one immutable Task24 v137 fixed-seed one-episode rollout."""

from __future__ import annotations

import csv
import json
import sys
from pathlib import Path


OFFICIAL_COMMIT = "62214036103ee8d5fef9b475dd8b344b6e2cfc03"
ORACLE_FIELDS = (
    "oracle_hold_release_next",
    "oracle_force_initial_prompt",
    "oracle_initial_stage_lock",
    "oracle_stage_advance_next",
    "oracle_monotonic_sequence_lock",
    "oracle_stage_lock_until_done",
)


def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def as_int(value: object) -> int:
    return int(str(value))


def as_float(value: object) -> float:
    return float(str(value))


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: validate_episode.py <run-dir> <expected-seed>", file=sys.stderr)
        return 2

    run_dir = Path(sys.argv[1]).resolve()
    expected_seed = int(sys.argv[2])
    result: dict[str, object] = {
        "valid": False,
        "run_dir": str(run_dir),
        "expected_seed": expected_seed,
        "reasons": [],
    }
    reasons: list[str] = result["reasons"]  # type: ignore[assignment]

    summary_path = run_dir / "summary.tsv"
    episodes_path = run_dir / "official_episodes.tsv"
    manifest_path = run_dir / "run_manifest.json"
    snapshot_commit_path = run_dir / "code_snapshot" / "official_commit.txt"
    for path in (summary_path, episodes_path, manifest_path, snapshot_commit_path):
        if not path.is_file():
            reasons.append(f"missing:{path.name}")

    if not reasons:
        try:
            summary_rows = read_tsv(summary_path)
            episode_rows = read_tsv(episodes_path)
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            snapshot_commit = snapshot_commit_path.read_text(encoding="utf-8").strip()

            if len(summary_rows) != 1:
                reasons.append(f"summary_rows={len(summary_rows)}")
            if len(episode_rows) != 1:
                reasons.append(f"episode_rows={len(episode_rows)}")
            if not reasons:
                summary = summary_rows[0]
                episode = episode_rows[0]
                if summary.get("task_id") != "24" or summary.get("status") != "completed":
                    reasons.append("summary_not_completed_task24")
                if episode.get("task_id") != "24" or episode.get("ep") != "0":
                    reasons.append("episode_not_single_task24_ep0")
                if as_int(episode.get("seed")) != expected_seed:
                    reasons.append(f"episode_seed={episode.get('seed')}")
                if as_int(manifest.get("seed")) != expected_seed:
                    reasons.append(f"manifest_seed={manifest.get('seed')}")
                if as_int(manifest.get("num_trials")) != 1:
                    reasons.append(f"manifest_num_trials={manifest.get('num_trials')}")
                if manifest.get("mode") != "vlm_free":
                    reasons.append(f"mode={manifest.get('mode')}")
                if manifest.get("robomemarena_official_commit") != OFFICIAL_COMMIT:
                    reasons.append("manifest_official_commit_mismatch")
                if snapshot_commit != OFFICIAL_COMMIT:
                    reasons.append("snapshot_official_commit_mismatch")
                for field in ORACLE_FIELDS:
                    if as_int(manifest.get(field)) != 0:
                        reasons.append(f"{field}={manifest.get(field)}")

                result.update(
                    {
                        "seed": as_int(episode.get("seed")),
                        "stage_score_pct": as_float(episode.get("score_pct")),
                        "stage_success": episode.get("stage_success") == "Y",
                        "goal_success": episode.get("goal_success") == "Y",
                        "official_commit": OFFICIAL_COMMIT,
                    }
                )
        except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as exc:
            reasons.append(f"parse_error:{type(exc).__name__}:{exc}")

    result["valid"] = not reasons
    print(json.dumps(result, sort_keys=True))
    return 0 if result["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
