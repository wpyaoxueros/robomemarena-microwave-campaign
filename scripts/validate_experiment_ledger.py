#!/usr/bin/env python3
"""Validate the append-only experiment ledger before an experiment commit."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
LEDGER = REPO_ROOT / "records" / "EXPERIMENT_LEDGER.jsonl"
ALLOWED_STATUS = {
    "SUCCESS",
    "FAILED",
    "PARTIAL",
    "REPORTED",
    "INVALID",
    "IN_PROGRESS",
}
ALLOWED_QUALIFICATION = {
    "current_strict",
    "latest_pinned",
    "historical_pinned",
    "reported_unrecovered",
    "diagnostic",
    "excluded",
    "legacy_termination",
    "pre_correction",
}
REQUIRED_FIELDS = {
    "record_id",
    "task_id",
    "recorded_at",
    "status",
    "qualification",
    "scorer_commit",
    "vla_checkpoint",
    "vla_norm",
    "norm_sha256",
    "vlm_checkpoint",
    "entrypoint",
    "seed_spec",
    "topology",
    "oracle_prompt_injection",
    "object_anchor",
    "episodes",
    "stage_successes",
    "goal_successes",
    "output_root",
    "result_path",
    "manifest_path",
    "video_root",
    "source_docs",
    "notes",
}
PATH_FIELDS = (
    "vla_checkpoint",
    "vla_norm",
    "vlm_checkpoint",
    "entrypoint",
    "output_root",
    "result_path",
    "manifest_path",
    "video_root",
)


def is_unrecovered(value: object) -> bool:
    return value in (None, "", "UNRECOVERED")


def resolve_path(value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else REPO_ROOT / path


def validate_record(record: dict, line_number: int, check_local: bool) -> list[str]:
    errors: list[str] = []
    missing = sorted(REQUIRED_FIELDS - record.keys())
    if missing:
        return [f"line {line_number}: missing fields: {', '.join(missing)}"]

    if record["status"] not in ALLOWED_STATUS:
        errors.append(f"line {line_number}: invalid status {record['status']!r}")
    if record["qualification"] not in ALLOWED_QUALIFICATION:
        errors.append(
            f"line {line_number}: invalid qualification {record['qualification']!r}"
        )
    if not isinstance(record["task_id"], int) or record["task_id"] < 1:
        errors.append(f"line {line_number}: task_id must be a positive integer")
    if not isinstance(record["episodes"], int) or record["episodes"] < 0:
        errors.append(f"line {line_number}: episodes must be a non-negative integer")
    for key in ("stage_successes", "goal_successes"):
        value = record[key]
        if value is not None and (not isinstance(value, int) or value < 0):
            errors.append(f"line {line_number}: {key} must be null or a non-negative integer")
        if isinstance(value, int) and value > record["episodes"]:
            errors.append(f"line {line_number}: {key} exceeds episodes")
    if record["status"] == "SUCCESS" and record["stage_successes"] in (None, 0):
        errors.append(f"line {line_number}: SUCCESS must include at least one stage success")
    if record["status"] == "FAILED" and record["stage_successes"] not in (None, 0):
        errors.append(f"line {line_number}: FAILED cannot claim a full stage success")
    if record["status"] == "PARTIAL" and record["episodes"] == 0:
        errors.append(f"line {line_number}: PARTIAL must include at least one valid episode")
    if record["status"] == "REPORTED" and record["qualification"] != "reported_unrecovered":
        errors.append(
            f"line {line_number}: REPORTED requires qualification='reported_unrecovered'"
        )
    if record["qualification"] == "current_strict" and record.get("post_goal_steps") != 200:
        errors.append(f"line {line_number}: current_strict requires post_goal_steps=200")
    if not isinstance(record["source_docs"], list) or not record["source_docs"]:
        errors.append(f"line {line_number}: source_docs must be a non-empty list")
    if record["qualification"] != "reported_unrecovered":
        for key in ("scorer_commit", "vla_checkpoint", "vla_norm", "norm_sha256", "vlm_checkpoint", "entrypoint"):
            if is_unrecovered(record[key]):
                errors.append(f"line {line_number}: {key} cannot be UNRECOVERED")

    for doc in record["source_docs"]:
        if not isinstance(doc, str) or not doc:
            errors.append(f"line {line_number}: invalid source_docs entry")
            continue
        if not resolve_path(doc).is_file():
            errors.append(f"line {line_number}: source document missing: {doc}")

    if check_local:
        for key in PATH_FIELDS:
            value = record[key]
            if is_unrecovered(value):
                continue
            try:
                exists = resolve_path(value).exists()
            except OSError as exc:
                errors.append(
                    f"line {line_number}: local path inaccessible for {key}: "
                    f"{value} ({exc.__class__.__name__}: {exc})"
                )
                continue
            if not exists:
                errors.append(f"line {line_number}: local path missing for {key}: {value}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check-local", action="store_true")
    args = parser.parse_args()

    errors: list[str] = []
    seen_ids: set[str] = set()
    records = 0
    for line_number, raw_line in enumerate(LEDGER.read_text(encoding="utf-8").splitlines(), 1):
        if not raw_line.strip():
            continue
        try:
            record = json.loads(raw_line)
        except json.JSONDecodeError as exc:
            errors.append(f"line {line_number}: invalid JSON: {exc.msg}")
            continue
        record_id = record.get("record_id")
        if record_id in seen_ids:
            errors.append(f"line {line_number}: duplicate record_id {record_id!r}")
        else:
            seen_ids.add(record_id)
        errors.extend(validate_record(record, line_number, args.check_local))
        records += 1

    if errors:
        print("EXPERIMENT_LEDGER: FAIL", file=sys.stderr)
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"EXPERIMENT_LEDGER: PASS ({records} records)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
