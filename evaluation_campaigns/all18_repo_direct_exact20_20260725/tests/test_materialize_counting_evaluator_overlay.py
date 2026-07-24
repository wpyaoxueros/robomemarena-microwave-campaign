#!/usr/bin/env python3
"""Contract test for the job-local counting evaluator source overlay."""

from __future__ import annotations

import json
import pathlib
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
BUILDER = ROOT / "scripts" / "materialize_counting_evaluator_overlay.py"
PACK = REPO / "counting" / "task6_fixed_seed_latest_d9f83ac"
SOURCE_ROOT = pathlib.Path(
    "/data/user/hlei573/vla_memory_experiments/official_runtime_sources/"
    "RoboMemArena_openhelix_d9f83ac_20260725"
)


def main() -> int:
    with tempfile.TemporaryDirectory() as temp_dir:
        output = pathlib.Path(temp_dir) / "overlay"
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
        link = output / "source" / "RoboMemArena_d9f83ac"
        assert link.is_symlink()
        assert link.resolve() == SOURCE_ROOT.resolve()
        assert (output / "evaluators" / "eval_counting_autonomous_guarded_d9f83ac.py").is_file()
        assert (output / "scripts" / "serve_policy_selfcontained.py").is_file()
        assert (output / "scripts" / "run_task6_fixed_seed_repeat_worker.sh").is_file()
        manifest = json.loads((output / "overlay_manifest.json").read_text(encoding="utf-8"))
        assert manifest["source_root"] == str(SOURCE_ROOT.resolve())
        assert manifest["frozen_pack"] == str(PACK.resolve())
        assert "run_task6_fixed_seed_repeat_worker.sh" in manifest["script_hashes"]
    print("PASS counting evaluator overlay contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
