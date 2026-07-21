#!/usr/bin/env python3
"""Resolve the Task21 anchor-data path without embedding a machine-specific path."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--data-root", type=Path, required=True)
    args = parser.parse_args()

    anchors = json.loads(args.template.read_text(encoding="utf-8"))
    token = "${TASK21_DATA_ROOT}"
    for anchor in anchors:
        value = anchor.get("anchor_hdf5")
        if not isinstance(value, str) or not value.startswith(f"{token}/"):
            raise ValueError(f"invalid anchor_hdf5 template: {value!r}")
        anchor["anchor_hdf5"] = str(args.data_root / value.removeprefix(f"{token}/"))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(anchors, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()

