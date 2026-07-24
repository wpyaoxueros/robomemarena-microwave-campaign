#!/usr/bin/env python3
"""Materialize a frozen counting evaluator with a read-only official source link."""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import shutil


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--frozen-pack", type=pathlib.Path, required=True)
    parser.add_argument("--source-root", type=pathlib.Path, required=True)
    parser.add_argument("--output", type=pathlib.Path, required=True)
    args = parser.parse_args()

    frozen_pack = args.frozen_pack.resolve()
    source_root = args.source_root.resolve()
    output = args.output.resolve()
    evaluator_source = frozen_pack / "evaluators"
    scripts_source = frozen_pack / "scripts"
    official_evaluator = (
        source_root
        / "evaluation_benchmark"
        / "async_vlm26_reference"
        / "eval_fullvlm26_async_vlm_vla.py"
    )
    for required_dir in (evaluator_source, scripts_source):
        if not required_dir.is_dir():
            raise FileNotFoundError(required_dir)
    if not official_evaluator.is_file():
        raise FileNotFoundError(official_evaluator)
    if output.exists():
        raise FileExistsError(output)

    shutil.copytree(
        evaluator_source,
        output / "evaluators",
        ignore=shutil.ignore_patterns("__pycache__", "*.pyc"),
    )
    shutil.copytree(
        scripts_source,
        output / "scripts",
        ignore=shutil.ignore_patterns("__pycache__", "*.pyc"),
    )
    source_link = output / "source" / "RoboMemArena_d9f83ac"
    source_link.parent.mkdir(parents=True, exist_ok=True)
    source_link.symlink_to(source_root, target_is_directory=True)

    copied_evaluators = output / "evaluators"
    evaluator_hashes = {
        str(path.relative_to(copied_evaluators)): sha256(path)
        for path in sorted(copied_evaluators.glob("*.py"))
    }
    copied_scripts = output / "scripts"
    script_hashes = {
        str(path.relative_to(copied_scripts)): sha256(path)
        for path in sorted(copied_scripts.glob("*"))
        if path.is_file()
    }
    manifest = {
        "frozen_pack": str(frozen_pack),
        "source_root": str(source_root),
        "source_link": str(source_link),
        "official_evaluator": str(official_evaluator),
        "official_evaluator_sha256": sha256(official_evaluator),
        "evaluator_hashes": evaluator_hashes,
        "script_hashes": script_hashes,
    }
    (output / "overlay_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"evaluator_overlay={output}")
    print(f"official_evaluator_sha256={manifest['official_evaluator_sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
