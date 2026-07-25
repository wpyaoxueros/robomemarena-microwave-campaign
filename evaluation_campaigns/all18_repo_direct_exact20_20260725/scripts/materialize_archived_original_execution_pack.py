#!/usr/bin/env python3
"""Materialize the exact code snapshots saved with archived successful runs."""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import shutil


TASK_ROOTS = {
    2: pathlib.Path(
        "/data/user/zzhang510/hlei573_borrow_outputs/"
        "repro20_official66e789_task2bddlfix_20260704_1827/task2"
    ),
    3: pathlib.Path(
        "/data/user/zzhang510/hlei573_borrow_outputs/"
        "repro20_official66e789_20260704_1815/task3"
    ),
    12: pathlib.Path(
        "/data/user/zzhang510/hlei573_borrow_outputs/"
        "repro20_official66e789_20260704_1815/task12"
    ),
    13: pathlib.Path(
        "/data/user/zzhang510/hlei573_borrow_outputs/"
        "repro20_official66e789_20260704_1815/task13"
    ),
    18: pathlib.Path(
        "/data/user/zzhang510/hlei573_borrow_outputs/"
        "repro20_official66e789_20260704_1815/task18"
    ),
    25: pathlib.Path(
        "/data/user/zzhang510/hlei573_borrow_outputs/"
        "repro20_official66e789_20260704_1815/task25"
    ),
    26: pathlib.Path(
        "/data/user/zzhang510/hlei573_borrow_outputs/"
        "repro20_official66e789_20260704_1815/task26"
    ),
}

REQUIRED_CODE_FILES = (
    "run_one.sh",
    "run_tasks2_26_sync_hold_eval.sh",
    "eval_tasks2_26_sync_endpose_hold_officialscore.py",
    "eval_common.py",
    "task2_26_reference_stage.py",
)
REQUIRED_REPRO_FILES = (
    "base_eval_py__eval_tasks2_26_vlm_vla.py",
    "task_config__fullvlm_v2_26_memory_tasks.json",
    "eval_py__eval_tasks2_26_sync_endpose_hold_officialscore.py",
    "launcher__run_tasks2_26_sync_hold_eval.sh",
)


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def only_repro_snapshot(task_root: pathlib.Path) -> pathlib.Path:
    manifests = sorted(task_root.glob("logs_task_sync_hold/*/repro_snapshot/*/MANIFEST.txt"))
    if len(manifests) != 1:
        raise RuntimeError(
            f"expected exactly one repro snapshot under {task_root}, found {len(manifests)}"
        )
    return manifests[0].parent


def collect_hashes(root: pathlib.Path) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for path in sorted(item for item in root.rglob("*") if item.is_file()):
        hashes[str(path.relative_to(root))] = sha256(path)
    return hashes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--task-id", type=int, choices=sorted(TASK_ROOTS), required=True)
    parser.add_argument("--output", type=pathlib.Path, required=True)
    args = parser.parse_args()

    task_root = TASK_ROOTS[args.task_id].resolve()
    code_snapshot = task_root / "code_snapshot"
    repro_snapshot = only_repro_snapshot(task_root)
    repro_files = repro_snapshot / "files"
    output = args.output.resolve()

    if output.exists():
        raise FileExistsError(output)
    for relative in REQUIRED_CODE_FILES:
        if not (code_snapshot / relative).is_file():
            raise FileNotFoundError(code_snapshot / relative)
    for relative in REQUIRED_REPRO_FILES:
        if not (repro_files / relative).is_file():
            raise FileNotFoundError(repro_files / relative)

    output.mkdir(parents=True)
    shutil.copytree(code_snapshot, output / "code_snapshot", copy_function=shutil.copy2)
    shutil.copytree(repro_files, output / "repro_snapshot" / "files", copy_function=shutil.copy2)
    for name in ("MANIFEST.txt", "sha256sums.txt", "env.sorted"):
        source = repro_snapshot / name
        if source.is_file():
            shutil.copy2(source, output / "repro_snapshot" / name)

    original_hashes = {
        **{f"code_snapshot/{key}": value for key, value in collect_hashes(code_snapshot).items()},
        **{f"repro_snapshot/files/{key}": value for key, value in collect_hashes(repro_files).items()},
    }
    execution_hashes = {
        **{
            f"code_snapshot/{key}": value
            for key, value in collect_hashes(output / "code_snapshot").items()
        },
        **{
            f"repro_snapshot/files/{key}": value
            for key, value in collect_hashes(output / "repro_snapshot" / "files").items()
        },
    }
    if original_hashes != execution_hashes:
        raise RuntimeError("materialized execution pack differs from archived snapshots")

    manifest = {
        "task_id": args.task_id,
        "original_task_root": str(task_root),
        "original_code_snapshot": str(code_snapshot.resolve()),
        "original_repro_snapshot": str(repro_snapshot.resolve()),
        "original_repro_manifest_sha256": sha256(repro_snapshot / "MANIFEST.txt"),
        "files": execution_hashes,
    }
    (output / "execution_pack_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"execution_pack={output}")
    print(f"original_repro_snapshot={repro_snapshot}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
