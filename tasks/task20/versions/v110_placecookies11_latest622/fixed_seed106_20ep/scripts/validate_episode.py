#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path


EXPECTED_ORACLE_FLAGS = (
    "ORACLE_FORCE_INITIAL_PROMPT",
    "ORACLE_HOLD_RELEASE_NEXT",
    "ORACLE_INITIAL_STAGE_LOCK",
    "ORACLE_MONOTONIC_SEQUENCE_LOCK",
    "ORACLE_STAGE_ADVANCE_NEXT",
    "ORACLE_STAGE_LOCK_UNTIL_DONE",
)
VARIANT_CONFIG = (
    "task20_eef_open105_pickcookies03_placecookies11_"
    "pickchoc045_placechoc04_tol_20260722.json"
)
EXPECTED_NORM_SHA256 = "4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a"
EXPECTED_OFFICIAL_COMMIT = "62214036103ee8d5fef9b475dd8b344b6e2cfc03"
EXPECTED_VLM_VARIANT_ID = "task20_mwvlm_no_completed_v49_ckpt24"


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _load_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text().splitlines():
        if "=" not in raw_line:
            continue
        key, value = raw_line.split("=", 1)
        values[key] = value
    return values


def validate_run(run_dir: Path) -> dict[str, object]:
    run_dir = run_dir.resolve()
    summary_path = run_dir / "summary.tsv"
    with summary_path.open(newline="") as handle:
        rows = list(csv.DictReader(handle, delimiter="\t"))
    if len(rows) != 1:
        raise ValueError(f"expected one summary row, found {len(rows)}")
    row = rows[0]
    if row["task_id"] != "20" or row["status"] != "completed" or row["error"]:
        raise ValueError(f"invalid summary row: {row}")

    video_dir = Path(row["video_dir"]).resolve()
    if run_dir not in video_dir.parents:
        raise ValueError(f"video directory escaped run directory: {video_dir}")
    main_videos = sorted(
        path
        for path in video_dir.glob("task20_*_ep0_seed*.mp4")
        if not path.name.endswith("_wrist.mp4") and path.stat().st_size > 1000
    )
    if len(main_videos) != 1:
        raise ValueError(f"expected one full main video, found {main_videos}")

    shell_vars_path = run_dir / "logs" / "shell_vars.before_eval"
    shell_vars = _load_env(shell_vars_path)
    tolerance_path = shell_vars.get("ENDPOSE_HOLD_POS_TOL_BY_SUBTASK_FILE", "")
    if not tolerance_path.endswith(VARIANT_CONFIG):
        raise ValueError(f"wrong tolerance config: {tolerance_path}")
    for flag in EXPECTED_ORACLE_FLAGS:
        if shell_vars.get(flag) != "0":
            raise ValueError(f"{flag} is not zero: {shell_vars.get(flag)!r}")
    if shell_vars.get("VLM_VARIANT_ID") != EXPECTED_VLM_VARIANT_ID:
        raise ValueError(f"wrong VLM variant: {shell_vars.get('VLM_VARIANT_ID')!r}")

    norm_repo = Path(shell_vars.get("VLA_REPO_ID", "")).resolve()
    norm_path = norm_repo / "norm_stats.json"
    if not norm_path.is_file():
        raise ValueError(f"missing norm_stats.json under VLA_REPO_ID: {norm_repo}")
    norm_sha256 = _sha256(norm_path)
    if norm_sha256 != EXPECTED_NORM_SHA256:
        raise ValueError(f"wrong norm checksum: {norm_sha256}")

    snapshot = run_dir / "code_snapshot"
    official_commit = (snapshot / "official_commit.txt").read_text().strip()
    if official_commit != EXPECTED_OFFICIAL_COMMIT:
        raise ValueError(f"wrong official commit: {official_commit}")

    config = snapshot / "package" / "config" / VARIANT_CONFIG
    config_data = json.loads(config.read_text())
    if float(config_data["place cookies"]) != 0.11:
        raise ValueError(f"wrong place-cookies tolerance: {config_data}")

    checksum_file = snapshot / "artifact_sha256.tsv"
    for line in checksum_file.read_text().splitlines():
        expected, relative = line.split(maxsplit=1)
        relative = relative.removeprefix("*").removeprefix("./")
        artifact = snapshot / relative
        actual = _sha256(artifact)
        if actual != expected:
            raise ValueError(f"checksum mismatch: {artifact}")

    return {
        "run_dir": str(run_dir),
        "stage_score_pct": float(row["stage_score_pct"]),
        "stage_success_rate": float(row["stage_success_rate"]),
        "goal_success_rate": float(row["goal_success_rate"]),
        "video": str(main_videos[0]),
        "video_size": main_videos[0].stat().st_size,
        "norm_repo": str(norm_repo),
        "norm_sha256": norm_sha256,
        "official_commit": official_commit,
        "vlm_variant_id": EXPECTED_VLM_VARIANT_ID,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("run_dir", type=Path)
    args = parser.parse_args()
    print(json.dumps(validate_run(args.run_dir), sort_keys=True))


if __name__ == "__main__":
    main()
