#!/usr/bin/env python3
"""Contract test for the Task22 v3 native boundary-data builder."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
BUILDER = REPO / "data" / "build_task22_v3_native_pour_boundary.py"


def row(qid: str, primitive: str, stem: str, window_start: int, repeat_index: int) -> dict:
    return {
        "qid": qid,
        "messages": [
            {"role": "user", "content": "synthetic"},
            {"role": "assistant", "content": json.dumps({"current_primitive": primitive, "keyframe_positions": []})},
        ],
        "images": ["/synthetic/a.png", "/synthetic/w.png"],
        "metadata": {
            "task_id": 22,
            "primitive_stem": stem,
            "current_primitive": primitive,
            "window_start": window_start,
            "repeat_index": repeat_index,
        },
    }


def main() -> int:
    rows = [
        row("pick", "pick tomato", "pick_tomato", 0, 0),
        row("boundary", "pour first", "pour_first", 0, 0),
        row("other_repeat", "pour first", "pour_first", 0, 1),
        row("other_window", "pour first", "pour_first", 1, 0),
        row("aside", "place tomato aside", "place_tomato_aside", 0, 0),
    ]
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        source = root / "source.jsonl"
        output = root / "output.jsonl"
        manifest = root / "manifest.json"
        source.write_bytes(b"".join((json.dumps(item, separators=(",", ":")) + "\n").encode("utf-8") for item in rows))
        result = subprocess.run(
            [sys.executable, str(BUILDER), "--source", str(source), "--output", str(output), "--manifest", str(manifest), "--copies", "3"],
            check=True,
            capture_output=True,
            text=True,
        )
        report = json.loads(result.stdout)
        assert report["source_rows"] == 5
        assert report["selected_canonical_rows"] == 1
        assert report["added_rows"] == 3
        assert report["output_rows"] == 8
        source_bytes = source.read_bytes()
        output_bytes = output.read_bytes()
        assert output_bytes.startswith(source_bytes)
        output_rows = [json.loads(line) for line in output_bytes.splitlines()]
        assert [item["qid"] for item in output_rows[:5]] == [item["qid"] for item in rows]
        clones = output_rows[5:]
        assert [item["qid"] for item in clones] == [
            "boundary__v3_native_pour_boundary_copy01",
            "boundary__v3_native_pour_boundary_copy02",
            "boundary__v3_native_pour_boundary_copy03",
        ]
        for clone in clones:
            assert json.loads(clone["messages"][-1]["content"])["current_primitive"] == "pour first"
            assert clone["images"] == rows[1]["images"]
            assert clone["metadata"]["augmentation"]["runtime_oracle_used"] is False
        manifest_data = json.loads(manifest.read_text(encoding="utf-8"))
        assert manifest_data["selected_qids"] == ["boundary"]
        assert manifest_data["runtime_oracle_used"] is False
    print("task22 v3 data builder: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
