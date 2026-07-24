#!/usr/bin/env python3
"""Contract test for an immutable microwave package d9 scorer overlay."""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
REPO = ROOT.parent.parent
BUILDER = ROOT / "scripts" / "materialize_microwave_d9_overlay.py"
SOURCE_PACK = REPO / "tasks" / "task20"
SOURCE_ROOT = pathlib.Path(
    "/data/user/hlei573/vla_memory_experiments/official_runtime_sources/"
    "RoboMemArena_openhelix_d9f83ac_20260725"
)
OLD_COMMIT = "62214036103ee8d5fef9b475dd8b344b6e2cfc03"
NEW_COMMIT = "d9f83ac5182e25ad7f0a301a77a0b667f2392df1"
SOURCE_RUNNER = SOURCE_PACK / "scripts" / "run_task20_v110.sh"


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    source_before = sha256(SOURCE_RUNNER)
    assert OLD_COMMIT in SOURCE_RUNNER.read_text(encoding="utf-8")

    with tempfile.TemporaryDirectory() as temp_dir:
        output = pathlib.Path(temp_dir) / "task20_d9_overlay"
        subprocess.run(
            [
                sys.executable,
                str(BUILDER),
                "--source-pack",
                str(SOURCE_PACK),
                "--source-root",
                str(SOURCE_ROOT),
                "--source-commit",
                NEW_COMMIT,
                "--output",
                str(output),
            ],
            check=True,
        )

        overlay_runner = output / "scripts" / "run_task20_v110.sh"
        overlay_validator = (
            output
            / "versions"
            / "v110_placecookies11_latest622"
            / "fixed_seed106_20ep"
            / "scripts"
            / "validate_episode.py"
        )
        assert NEW_COMMIT in overlay_runner.read_text(encoding="utf-8")
        assert OLD_COMMIT not in overlay_runner.read_text(encoding="utf-8")
        assert NEW_COMMIT in overlay_validator.read_text(encoding="utf-8")
        assert (output / "source" / "RoboMemArena_d9f83ac").resolve() == SOURCE_ROOT.resolve()

        manifest = json.loads((output / "overlay_manifest.json").read_text(encoding="utf-8"))
        assert manifest["source_pack"] == str(SOURCE_PACK.resolve())
        assert manifest["source_root"] == str(SOURCE_ROOT.resolve())
        assert manifest["source_commit"] == NEW_COMMIT
        assert manifest["replaced_commit"] == OLD_COMMIT
        assert "scripts/run_task20_v110.sh" in manifest["replaced_files"]

    assert sha256(SOURCE_RUNNER) == source_before
    print("PASS microwave d9 overlay contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
