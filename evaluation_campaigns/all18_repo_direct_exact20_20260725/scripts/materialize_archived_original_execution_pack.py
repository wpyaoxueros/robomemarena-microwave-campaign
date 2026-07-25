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
OFFICIAL_SCRIPT_FILES = (
    "eval_common.py",
    "eval_task1_only.py",
    "policy_adapter.py",
    "run_all_tasks1_26.py",
    "task2_26_reference_stage.py",
)
ORIGINAL_RMA_ROOT = pathlib.Path(
    "/data/user/hlei573/tmp/rma_refeval_fresh_20260513_052445/RoboMemArena"
)
ORIGINAL_RUNTIME_DIR = ORIGINAL_RMA_ROOT / "evaluation_benchmark" / "openpi_minimal_runtime"
ORIGINAL_BDDL_DIR = ORIGINAL_RMA_ROOT / "bddl"
FROZEN_BASE_EVALUATOR_RELATIVE = pathlib.Path(
    "RoboMemArena/evaluation_benchmark/reference_evaluation/"
    "tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py"
)
FROZEN_RUNTIME_RELATIVE = pathlib.Path(
    "RoboMemArena/evaluation_benchmark/openpi_minimal_runtime"
)
FROZEN_DRIVER_EVALUATOR_RELATIVE = pathlib.Path(
    "driver/eval_tasks2_26_sync_endpose_hold_officialscore.py"
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


def materialize_base_evaluator_runtime(repro_files: pathlib.Path, output: pathlib.Path) -> dict[str, str]:
    """Recreate the base evaluator's original relative-import layout.

    The archived evaluator derives ``openpi_minimal_runtime`` from its own
    path. Keeping the archived file only in ``repro_snapshot/files`` changes
    that derivation and makes the original launcher fail before rollout.
    """
    archived_base = repro_files / "base_eval_py__eval_tasks2_26_vlm_vla.py"
    original_base = (
        ORIGINAL_RMA_ROOT
        / "evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference"
        / "eval_tasks2_26_vlm_vla.py"
    )
    if not original_base.is_file():
        raise FileNotFoundError(original_base)
    if sha256(archived_base) != sha256(original_base):
        raise RuntimeError(
            "archived base evaluator does not match the original runtime source; "
            "refusing to mix code versions"
        )
    if not ORIGINAL_RUNTIME_DIR.is_dir():
        raise FileNotFoundError(ORIGINAL_RUNTIME_DIR)

    frozen_base = output / FROZEN_BASE_EVALUATOR_RELATIVE
    frozen_base.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(archived_base, frozen_base)

    frozen_runtime = output / FROZEN_RUNTIME_RELATIVE
    frozen_runtime.mkdir(parents=True, exist_ok=True)
    for source in sorted(ORIGINAL_RUNTIME_DIR.glob("*.py")):
        shutil.copy2(source, frozen_runtime / source.name)

    if sha256(frozen_base) != sha256(archived_base):
        raise RuntimeError("frozen base evaluator copy hash mismatch")
    return {
        str(path.relative_to(output)): sha256(path)
        for path in sorted(
            [frozen_base, *(frozen_runtime / source.name for source in ORIGINAL_RUNTIME_DIR.glob("*.py"))]
        )
    }


def materialize_root_bddl(output: pathlib.Path) -> dict[str, str]:
    """Copy the original BDDL root required by the untouched runtime resolver."""
    if not ORIGINAL_BDDL_DIR.is_dir():
        raise FileNotFoundError(ORIGINAL_BDDL_DIR)
    frozen_bddl = output / "RoboMemArena" / "bddl"
    shutil.copytree(ORIGINAL_BDDL_DIR, frozen_bddl, copy_function=shutil.copy2)
    return {
        str(path.relative_to(output)): sha256(path)
        for path in sorted(item for item in frozen_bddl.rglob("*") if item.is_file())
    }


def materialize_isolated_driver(code_snapshot: pathlib.Path, output: pathlib.Path) -> pathlib.Path:
    """Place the archived outer evaluator in an import-isolated driver directory.

    The original evaluator ran from ``SOURCE_ROOT/evaluators``, which contained
    no ``eval_common.py``. Running it from the archived code snapshot would
    shadow the base evaluator's original runtime ``eval_common`` module.
    """
    source = code_snapshot / "eval_tasks2_26_sync_endpose_hold_officialscore.py"
    driver = output / FROZEN_DRIVER_EVALUATOR_RELATIVE
    driver.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, driver)
    if sha256(driver) != sha256(source):
        raise RuntimeError("isolated driver evaluator copy hash mismatch")
    return driver


def materialize_official_scripts(code_snapshot: pathlib.Path, output: pathlib.Path) -> tuple[pathlib.Path, dict[str, str]]:
    """Restore the archived official scripts at their original relative path."""
    scripts_dir = output / "RoboMemArena" / "evaluation_benchmark" / "scripts"
    scripts_dir.mkdir(parents=True, exist_ok=True)
    for name in OFFICIAL_SCRIPT_FILES:
        source = code_snapshot / name
        if not source.is_file():
            raise FileNotFoundError(source)
        shutil.copy2(source, scripts_dir / name)

    source_bddl = code_snapshot / "bddl"
    if not source_bddl.is_dir():
        raise FileNotFoundError(source_bddl)
    frozen_bddl = scripts_dir.parent / "bddl"
    shutil.copytree(source_bddl, frozen_bddl, copy_function=shutil.copy2)

    return scripts_dir, {
        str(path.relative_to(output)): sha256(path)
        for path in sorted(
            [
                *(scripts_dir / name for name in OFFICIAL_SCRIPT_FILES),
                *(item for item in frozen_bddl.rglob("*") if item.is_file()),
            ]
        )
    }


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
    isolated_driver = materialize_isolated_driver(code_snapshot, output)
    official_scripts_dir, official_script_hashes = materialize_official_scripts(code_snapshot, output)
    runtime_hashes = materialize_base_evaluator_runtime(repro_files, output)
    bddl_hashes = materialize_root_bddl(output)

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
        "frozen_base_evaluator": str((output / FROZEN_BASE_EVALUATOR_RELATIVE).resolve()),
        "frozen_driver_evaluator": str(isolated_driver.resolve()),
        "frozen_official_scripts_dir": str(official_scripts_dir.resolve()),
        "frozen_official_script_files": official_script_hashes,
        "frozen_runtime_files": runtime_hashes,
        "frozen_bddl_files": bddl_hashes,
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
