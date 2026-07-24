#!/usr/bin/env python3
"""Create a non-mutating d9 scorer overlay for a frozen microwave package."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import shutil
from typing import Iterable


TEXT_SUFFIXES = {".env", ".json", ".md", ".py", ".sh", ".tsv", ".txt", ".yaml", ".yml"}


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def iter_tree_entries(root: pathlib.Path) -> Iterable[pathlib.Path]:
    for path in sorted(root.rglob("*"), key=lambda candidate: str(candidate.relative_to(root))):
        yield path


def tree_hash(root: pathlib.Path) -> str:
    digest = hashlib.sha256()
    for path in iter_tree_entries(root):
        relative = path.relative_to(root).as_posix()
        if path.is_symlink():
            value = f"L\\0{relative}\\0{os.readlink(path)}\\n"
        elif path.is_dir():
            value = f"D\\0{relative}\\n"
        elif path.is_file():
            value = f"F\\0{relative}\\0{sha256(path)}\\n"
        else:
            value = f"O\\0{relative}\\n"
        digest.update(value.encode("utf-8"))
    return digest.hexdigest()


def replace_commit_references(
    output: pathlib.Path,
    replaced_commit: str,
    source_commit: str,
) -> dict[str, dict[str, str]]:
    replacements: dict[str, dict[str, str]] = {}
    for path in iter_tree_entries(output):
        if not path.is_file() or path.suffix not in TEXT_SUFFIXES:
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if replaced_commit not in content:
            continue
        before = sha256(path)
        path.write_text(content.replace(replaced_commit, source_commit), encoding="utf-8")
        replacements[path.relative_to(output).as_posix()] = {
            "before_sha256": before,
            "after_sha256": sha256(path),
        }
    return replacements


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-pack", type=pathlib.Path, required=True)
    parser.add_argument("--source-root", type=pathlib.Path, required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--output", type=pathlib.Path, required=True)
    parser.add_argument(
        "--replaced-commit",
        default="62214036103ee8d5fef9b475dd8b344b6e2cfc03",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source_pack = args.source_pack.resolve()
    source_root = args.source_root.resolve()
    output = args.output.resolve()
    scorer = source_root / "evaluation_benchmark" / "scripts" / "task2_26_reference_stage.py"

    if not source_pack.is_dir():
        raise FileNotFoundError(f"missing frozen package: {source_pack}")
    if not scorer.is_file():
        raise FileNotFoundError(f"missing d9 scorer: {scorer}")
    if output.exists():
        raise FileExistsError(f"overlay already exists: {output}")

    source_tree_sha256 = tree_hash(source_pack)
    shutil.copytree(
        source_pack,
        output,
        symlinks=True,
        ignore=shutil.ignore_patterns("__pycache__", "*.pyc", ".pytest_cache"),
    )
    replacements = replace_commit_references(
        output,
        args.replaced_commit,
        args.source_commit,
    )
    if not replacements:
        raise RuntimeError(
            f"no references to {args.replaced_commit} found under {source_pack}; refusing empty overlay"
        )

    source_link = output / "source" / "RoboMemArena_d9f83ac"
    source_link.parent.mkdir(parents=True, exist_ok=True)
    source_link.symlink_to(source_root, target_is_directory=True)

    manifest = {
        "source_pack": str(source_pack),
        "source_pack_tree_sha256": source_tree_sha256,
        "source_root": str(source_root),
        "source_commit": args.source_commit,
        "source_scorer": str(scorer),
        "source_scorer_sha256": sha256(scorer),
        "source_link": str(source_link),
        "replaced_commit": args.replaced_commit,
        "replaced_files": sorted(replacements),
        "replacement_hashes": replacements,
        "overlay_tree_sha256_before_manifest": tree_hash(output),
    }
    (output / "overlay_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"microwave_overlay={output}")
    print(f"source_scorer_sha256={manifest['source_scorer_sha256']}")
    print(f"replaced_files={len(replacements)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
