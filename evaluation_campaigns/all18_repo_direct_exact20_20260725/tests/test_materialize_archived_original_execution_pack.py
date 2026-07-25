#!/usr/bin/env python3
"""Contract test for materializing archived exact-success execution snapshots."""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
BUILDER = ROOT / "scripts" / "materialize_archived_original_execution_pack.py"
TASK2_ROOT = pathlib.Path(
    "/data/user/zzhang510/hlei573_borrow_outputs/"
    "repro20_official66e789_task2bddlfix_20260704_1827/task2"
)
TASK18_ROOT = pathlib.Path(
    "/data/user/zzhang510/hlei573_borrow_outputs/"
    "repro20_official66e789_20260704_1815/task18"
)


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    with tempfile.TemporaryDirectory() as temp_dir:
        for task_id, task_root, evaluator_sha in (
            (2, TASK2_ROOT, "cda4a23bf018f0c9e4ecb8bc6438d08fbfc6c7be92ebe655751604833dfe3ed4"),
            (18, TASK18_ROOT, "5a927406c3dd90e0ba833950e6456f88beb2cf28f8adc2707f1f2f8fdb67643b"),
        ):
            output = pathlib.Path(temp_dir) / f"execution_pack_task{task_id}"
            subprocess.run(
                [
                    sys.executable,
                    str(BUILDER),
                    "--task-id",
                    str(task_id),
                    "--output",
                    str(output),
                ],
                check=True,
            )

            original_launcher = task_root / "code_snapshot" / "run_tasks2_26_sync_hold_eval.sh"
            original_evaluator = task_root / "code_snapshot" / "eval_tasks2_26_sync_endpose_hold_officialscore.py"
            assert sha256(output / "code_snapshot" / original_launcher.name) == sha256(original_launcher)
            assert sha256(output / "code_snapshot" / original_evaluator.name) == sha256(original_evaluator)
            assert sha256(original_evaluator) == evaluator_sha

            manifests = list(task_root.glob("logs_task_sync_hold/*/repro_snapshot/*/MANIFEST.txt"))
            assert len(manifests) == 1
            original_repro = manifests[0].parent
            assert sha256(output / "repro_snapshot" / "files" / "base_eval_py__eval_tasks2_26_vlm_vla.py") == sha256(
                original_repro / "files" / "base_eval_py__eval_tasks2_26_vlm_vla.py"
            )

            manifest = json.loads((output / "execution_pack_manifest.json").read_text(encoding="utf-8"))
            assert manifest["task_id"] == task_id
            assert manifest["original_task_root"] == str(task_root.resolve())
            assert manifest["original_repro_snapshot"] == str(original_repro.resolve())
            assert manifest["files"]["code_snapshot/run_tasks2_26_sync_hold_eval.sh"] == sha256(original_launcher)
            assert manifest["files"]["code_snapshot/eval_tasks2_26_sync_endpose_hold_officialscore.py"] == sha256(
                original_evaluator
            )

    print("PASS archived original execution-pack contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
