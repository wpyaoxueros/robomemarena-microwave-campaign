#!/usr/bin/env python3
"""Create a byte-identical Task7 pack with its missing official source link."""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import shutil


REQUIRED_FILES = (
    "run_task7_8ep.sh",
    "scripts/run_autonomous_task.sh",
    "evaluators/eval_counting_autonomous_guarded_d9f83ac.py",
)


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
    official_evaluator = (
        source_root
        / "evaluation_benchmark"
        / "async_vlm26_reference"
        / "eval_fullvlm26_async_vlm_vla.py"
    )

    if not frozen_pack.is_dir():
        raise FileNotFoundError(frozen_pack)
    if not source_root.is_dir():
        raise FileNotFoundError(source_root)
    if not official_evaluator.is_file():
        raise FileNotFoundError(official_evaluator)
    if output.exists():
        raise FileExistsError(output)
    for relative in REQUIRED_FILES:
        if not (frozen_pack / relative).is_file():
            raise FileNotFoundError(frozen_pack / relative)

    shutil.copytree(
        frozen_pack,
        output,
        ignore=shutil.ignore_patterns("source", "__pycache__", "*.pyc"),
    )
    source_link = output / "source" / "RoboMemArena_d9f83ac"
    source_link.parent.mkdir(parents=True, exist_ok=True)
    source_link.symlink_to(source_root, target_is_directory=True)

    frozen_hashes = {relative: sha256(frozen_pack / relative) for relative in REQUIRED_FILES}
    execution_hashes = {relative: sha256(output / relative) for relative in REQUIRED_FILES}
    if frozen_hashes != execution_hashes:
        raise RuntimeError("execution pack differs from the frozen Task7 package")

    manifest = {
        "frozen_pack": str(frozen_pack),
        "source_root": str(source_root),
        "source_link": str(source_link),
        "official_evaluator": str(official_evaluator),
        "official_evaluator_sha256": sha256(official_evaluator),
        "frozen_file_sha256": frozen_hashes,
        "execution_file_sha256": execution_hashes,
    }
    (output / "execution_pack_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"execution_pack={output}")
    print(f"official_evaluator_sha256={manifest['official_evaluator_sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
