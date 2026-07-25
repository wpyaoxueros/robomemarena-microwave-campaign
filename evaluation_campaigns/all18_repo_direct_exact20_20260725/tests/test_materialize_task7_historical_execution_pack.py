#!/usr/bin/env python3
"""Contract test for the byte-identical Task7 historical execution pack."""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
BUILDER = ROOT / "scripts" / "materialize_task7_historical_execution_pack.py"
PACK = REPO / "counting" / "task7_vlm35999_latest_d9f83ac_hardcase500_20260724"
SOURCE_ROOT = pathlib.Path(
    "/data/user/hlei573/vla_memory_experiments/official_runtime_sources/"
    "RoboMemArena_openhelix_d9f83ac_20260725"
)


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    with tempfile.TemporaryDirectory() as temp_dir:
        output = pathlib.Path(temp_dir) / "execution_pack"
        subprocess.run(
            [
                sys.executable,
                str(BUILDER),
                "--frozen-pack",
                str(PACK),
                "--source-root",
                str(SOURCE_ROOT),
                "--output",
                str(output),
            ],
            check=True,
        )

        source_link = output / "source" / "RoboMemArena_d9f83ac"
        assert source_link.is_symlink()
        assert source_link.resolve() == SOURCE_ROOT.resolve()

        for relative in (
            "run_task7_8ep.sh",
            "scripts/run_autonomous_task.sh",
            "evaluators/eval_counting_autonomous_guarded_d9f83ac.py",
        ):
            assert sha256(output / relative) == sha256(PACK / relative), relative

        manifest = json.loads((output / "execution_pack_manifest.json").read_text(encoding="utf-8"))
        assert manifest["frozen_pack"] == str(PACK.resolve())
        assert manifest["source_root"] == str(SOURCE_ROOT.resolve())
        assert manifest["frozen_file_sha256"]["run_task7_8ep.sh"] == sha256(PACK / "run_task7_8ep.sh")
        assert manifest["execution_file_sha256"]["run_task7_8ep.sh"] == sha256(output / "run_task7_8ep.sh")

    print("PASS Task7 historical execution-pack contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
