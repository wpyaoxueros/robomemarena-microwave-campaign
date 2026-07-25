#!/usr/bin/env python3
"""Create and track canonical owner-side evidence for one experiment run."""

from __future__ import annotations

import argparse
import csv
import fcntl
import getpass
import json
import os
import re
import shutil
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ROOT = REPO_ROOT / "evidence"
RUN_ID_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,127}\Z")
ALLOWED_STATUSES = {
    "prepared",
    "submitted",
    "running",
    "episode_complete",
    "completed",
    "failed",
}
REQUIRED_FIELDS = {
    "run_id",
    "campaign_id",
    "task_id",
    "submit_user",
    "seed_spec",
    "policy_seed",
    "episode_target",
    "post_goal_steps",
    "topology",
    "oracle_prompt_injection",
    "object_anchor",
    "fallback_used",
    "scorer_commit",
    "evaluator_commit",
    "launch_command",
    "vla_checkpoint",
    "vla_norm",
    "vlm_checkpoint",
    "evaluator_path",
    "scorer_path",
    "entrypoint",
}
ASSET_FIELDS = (
    "vla_checkpoint",
    "vla_norm",
    "vlm_checkpoint",
    "evaluator_path",
    "scorer_path",
    "entrypoint",
)
TSV_COLUMNS = (
    "timestamp",
    "run_id",
    "task_id",
    "status",
    "submit_user",
    "episodes_completed",
    "episode_target",
    "stage_successes",
    "goal_successes",
    "scorer_commit",
    "vla_checkpoint",
    "vla_norm",
    "vlm_checkpoint",
    "run_dir",
    "manifest_path",
)


class EvidenceError(RuntimeError):
    """A run is not eligible for canonical evidence storage."""


def timestamp() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def evidence_root() -> Path:
    configured = os.environ.get("CENTRAL_EVIDENCE_ROOT")
    return Path(configured).resolve() if configured else DEFAULT_ROOT.resolve()


def safe_run_dir(root: Path, run_id: str) -> Path:
    if not RUN_ID_PATTERN.fullmatch(run_id):
        raise EvidenceError("run_id must be one plain alphanumeric, '.', '_' or '-' component")
    runs_root = (root / "runs").resolve()
    candidate = (runs_root / run_id).resolve()
    if candidate.parent != runs_root:
        raise EvidenceError("run_id resolves outside the canonical runs directory")
    return candidate


def ensure_directory(path: Path, mode: int) -> None:
    if not path.exists():
        path.mkdir(parents=True, exist_ok=False)
        os.chmod(path, mode)
    if not path.is_dir():
        raise EvidenceError(f"not a directory: {path}")


def ensure_root(root: Path) -> None:
    ensure_directory(root, 0o2770)
    ensure_directory(root / "runs", 0o2770)
    if not os.access(root, os.R_OK | os.W_OK | os.X_OK):
        raise EvidenceError(f"canonical evidence root is not readable and writable: {root}")


def atomic_write(path: Path, content: str, mode: int = 0o660) -> None:
    fd, tmp_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(tmp_name, mode)
        os.replace(tmp_name, path)
    except BaseException:
        try:
            os.unlink(tmp_name)
        except FileNotFoundError:
            pass
        raise


def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    atomic_write(path, json.dumps(payload, indent=2, sort_keys=True) + "\n")


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise EvidenceError(f"manifest not found: {path}") from exc
    except json.JSONDecodeError as exc:
        raise EvidenceError(f"invalid manifest JSON: {path}: {exc.msg}") from exc
    if not isinstance(payload, dict):
        raise EvidenceError("manifest root must be a JSON object")
    return payload


def validate_payload(payload: dict[str, Any], actor: str) -> None:
    missing = sorted(REQUIRED_FIELDS - payload.keys())
    if missing:
        raise EvidenceError(f"manifest missing fields: {', '.join(missing)}")
    if payload["submit_user"] != actor:
        raise EvidenceError(
            f"submit_user {payload['submit_user']!r} does not match current user {actor!r}"
        )
    run_id = payload["run_id"]
    if not isinstance(run_id, str) or not RUN_ID_PATTERN.fullmatch(run_id):
        raise EvidenceError("run_id must be one plain alphanumeric, '.', '_' or '-' component")
    if not isinstance(payload["task_id"], int) or payload["task_id"] < 1:
        raise EvidenceError("task_id must be a positive integer")
    if not isinstance(payload["episode_target"], int) or payload["episode_target"] < 1:
        raise EvidenceError("episode_target must be a positive integer")
    if not isinstance(payload["post_goal_steps"], int) or payload["post_goal_steps"] < 0:
        raise EvidenceError("post_goal_steps must be a non-negative integer")
    if not isinstance(payload["launch_command"], (str, list)) or not payload["launch_command"]:
        raise EvidenceError("launch_command must be a non-empty string or list")
    for field in ("oracle_prompt_injection", "object_anchor", "fallback_used"):
        if not isinstance(payload[field], bool):
            raise EvidenceError(f"{field} must be boolean")
    if payload["fallback_used"]:
        raise EvidenceError("fallback_used=true is forbidden for a canonical run")
    for field in ("scorer_commit", "evaluator_commit"):
        if not isinstance(payload[field], str) or not payload[field].strip():
            raise EvidenceError(f"{field} must be a non-empty string")
    for field in ASSET_FIELDS:
        value = payload[field]
        if not isinstance(value, str) or not value:
            raise EvidenceError(f"asset path must be non-empty: {field}")
        asset = Path(value)
        if not asset.exists() or not os.access(asset, os.R_OK):
            raise EvidenceError(f"unreadable asset: {field}: {asset}")


def read_events(root: Path) -> list[dict[str, Any]]:
    registry = root / "RUN_REGISTRY.jsonl"
    if not registry.exists():
        return []
    events: list[dict[str, Any]] = []
    for number, line in enumerate(registry.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError as exc:
            raise EvidenceError(f"invalid registry JSON at line {number}: {exc.msg}") from exc
        if not isinstance(event, dict):
            raise EvidenceError(f"invalid registry event at line {number}")
        events.append(event)
    return events


def latest_events(events: list[dict[str, Any]]) -> list[dict[str, Any]]:
    latest: dict[str, dict[str, Any]] = {}
    for event in events:
        latest[str(event["run_id"])] = event
    return [latest[run_id] for run_id in sorted(latest)]


def write_projection(root: Path, events: list[dict[str, Any]]) -> None:
    rows = latest_events(events)
    lines: list[str] = []
    with tempfile.TemporaryFile(mode="w+", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=TSV_COLUMNS, delimiter="\t", extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow({column: row.get(column, "") for column in TSV_COLUMNS})
        handle.seek(0)
        lines.append(handle.read())
    atomic_write(root / "RUN_REGISTRY.tsv", "".join(lines))


def append_event(root: Path, event: dict[str, Any]) -> None:
    lock_path = root / ".registry.lock"
    lock_path.touch(exist_ok=True)
    os.chmod(lock_path, 0o660)
    with lock_path.open("a+", encoding="utf-8") as lock:
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        try:
            registry = root / "RUN_REGISTRY.jsonl"
            with registry.open("a", encoding="utf-8") as handle:
                handle.write(json.dumps(event, sort_keys=True) + "\n")
                handle.flush()
                os.fsync(handle.fileno())
            os.chmod(registry, 0o660)
            write_projection(root, read_events(root))
        finally:
            fcntl.flock(lock.fileno(), fcntl.LOCK_UN)


def event_from_manifest(manifest: dict[str, Any], status: str) -> dict[str, Any]:
    return {
        "timestamp": timestamp(),
        "run_id": manifest["run_id"],
        "task_id": manifest["task_id"],
        "status": status,
        "submit_user": manifest["submit_user"],
        "episodes_completed": manifest.get("episodes_completed", 0),
        "episode_target": manifest["episode_target"],
        "stage_successes": manifest.get("stage_successes", 0),
        "goal_successes": manifest.get("goal_successes", 0),
        "scorer_commit": manifest["scorer_commit"],
        "vla_checkpoint": manifest["vla_checkpoint"],
        "vla_norm": manifest["vla_norm"],
        "vlm_checkpoint": manifest["vlm_checkpoint"],
        "run_dir": manifest["run_dir"],
        "manifest_path": manifest["manifest_path"],
    }


def snapshot_file(source: Path, snapshot_dir: Path) -> None:
    if source.is_file():
        target = snapshot_dir / source.name
        if target.exists():
            target = snapshot_dir / f"{source.stem}_{abs(hash(str(source.resolve()))):x}{source.suffix}"
        shutil.copy2(source, target)
        os.chmod(target, 0o660)


def initialize(manifest_source: Path) -> dict[str, Any]:
    actor = getpass.getuser()
    payload = load_json(manifest_source)
    validate_payload(payload, actor)
    root = evidence_root()
    ensure_root(root)
    run_dir = safe_run_dir(root, payload["run_id"])
    if run_dir.exists():
        raise EvidenceError(f"canonical run directory already exists: {run_dir}")

    run_dir.mkdir(mode=0o2770)
    os.chmod(run_dir, 0o2770)
    for name in ("logs", "videos", "artifacts", "code_snapshot"):
        directory = run_dir / name
        directory.mkdir(mode=0o2770)
        os.chmod(directory, 0o2770)
    snapshot_file(manifest_source, run_dir / "code_snapshot")
    for field in ("evaluator_path", "scorer_path", "entrypoint"):
        snapshot_file(Path(payload[field]), run_dir / "code_snapshot")

    payload.update(
        {
            "schema_version": 1,
            "created_at": timestamp(),
            "status": "prepared",
            "run_dir": str(run_dir),
            "manifest_path": str(run_dir / "run_manifest.json"),
            "episodes_completed": 0,
            "stage_successes": 0,
            "goal_successes": 0,
            "canonical_evidence_root": str(root),
        }
    )
    atomic_write_json(run_dir / "run_manifest.json", payload)
    append_event(root, event_from_manifest(payload, "prepared"))
    return payload


def transition(
    run_id: str,
    status: str,
    episodes_completed: int | None,
    stage_successes: int | None,
    goal_successes: int | None,
) -> dict[str, Any]:
    if status not in ALLOWED_STATUSES - {"prepared"}:
        raise EvidenceError(f"unsupported transition status: {status}")
    root = evidence_root()
    ensure_root(root)
    manifest_path = safe_run_dir(root, run_id) / "run_manifest.json"
    manifest = load_json(manifest_path)
    if manifest["submit_user"] != getpass.getuser():
        raise EvidenceError("only the declared submit user may update this run")
    for field, value in (
        ("episodes_completed", episodes_completed),
        ("stage_successes", stage_successes),
        ("goal_successes", goal_successes),
    ):
        if value is not None:
            if value < 0:
                raise EvidenceError(f"{field} must be non-negative")
            manifest[field] = value
    if manifest["episodes_completed"] > manifest["episode_target"]:
        raise EvidenceError("episodes_completed exceeds episode_target")
    for field in ("stage_successes", "goal_successes"):
        if manifest[field] > manifest["episodes_completed"]:
            raise EvidenceError(f"{field} exceeds episodes_completed")
    manifest["status"] = status
    manifest["updated_at"] = timestamp()
    atomic_write_json(manifest_path, manifest)
    append_event(root, event_from_manifest(manifest, status))
    return manifest


def validate(run_id: str) -> dict[str, Any]:
    root = evidence_root()
    manifest = load_json(safe_run_dir(root, run_id) / "run_manifest.json")
    validate_payload(manifest, manifest["submit_user"])
    if Path(manifest["run_dir"]).resolve() != safe_run_dir(root, run_id):
        raise EvidenceError("manifest run_dir does not match canonical run directory")
    if Path(manifest["manifest_path"]).resolve() != safe_run_dir(root, run_id) / "run_manifest.json":
        raise EvidenceError("manifest_path does not match canonical run manifest")
    return manifest


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    commands = result.add_subparsers(dest="command", required=True)
    init = commands.add_parser("init")
    init.add_argument("--manifest", required=True, type=Path)
    transition_parser = commands.add_parser("transition")
    transition_parser.add_argument("--run-id", required=True)
    transition_parser.add_argument("--status", required=True)
    transition_parser.add_argument("--episodes-completed", type=int)
    transition_parser.add_argument("--stage-successes", type=int)
    transition_parser.add_argument("--goal-successes", type=int)
    validate_parser = commands.add_parser("validate")
    validate_parser.add_argument("--run-id", required=True)
    return result


def main() -> int:
    os.umask(0o007)
    args = parser().parse_args()
    try:
        if args.command == "init":
            manifest = initialize(args.manifest)
        elif args.command == "transition":
            manifest = transition(
                args.run_id,
                args.status,
                args.episodes_completed,
                args.stage_successes,
                args.goal_successes,
            )
        else:
            manifest = validate(args.run_id)
    except EvidenceError as exc:
        print(f"CENTRAL_EVIDENCE: FAIL: {exc}", file=sys.stderr)
        return 2
    print(json.dumps({"run_id": manifest["run_id"], "status": manifest["status"], "run_dir": manifest["run_dir"]}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
