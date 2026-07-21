#!/usr/bin/env python3
"""Regression test for the Task21 empty release-anchor configuration."""

from __future__ import annotations

import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "scripts" / "materialize_task21_paths.py"
SPEC = importlib.util.spec_from_file_location("materialize_task21_paths", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def main() -> None:
    payload = MODULE.materialize_template({"tasks": {}}, Path("/unused"))
    assert isinstance(payload, dict)
    assert isinstance(payload.get("tasks", payload), dict)
    assert payload == {"tasks": {}}

    legacy = MODULE.materialize_template([], Path("/unused"))
    assert legacy == []
    print("PASS: empty task-indexed release-anchor template satisfies evaluator contract")


if __name__ == "__main__":
    main()
