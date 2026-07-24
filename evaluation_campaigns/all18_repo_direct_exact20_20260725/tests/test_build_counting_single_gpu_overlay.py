#!/usr/bin/env python3
"""Contract test for the versioned single-GPU counting overlay builder."""

from __future__ import annotations

import pathlib
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
BUILDER = ROOT / "scripts" / "build_counting_single_gpu_overlay.py"
SOURCE = (
    ROOT.parents[1]
    / "counting"
    / "task16_vlm35999_d9f83ac_pourreturnassist_20260724"
    / "scripts"
    / "run_autonomous_task.sh"
)


def main() -> int:
    with tempfile.TemporaryDirectory() as temp_dir:
        output = pathlib.Path(temp_dir) / "overlay.sh"
        completed = subprocess.run(
            [sys.executable, str(BUILDER), "--source", str(SOURCE), "--output", str(output)],
            check=True,
            text=True,
            capture_output=True,
        )
        text = output.read_text(encoding="utf-8")

    assert "FROZEN_PACK_DIR" in text
    assert 'CUDA_VISIBLE_DEVICES="${VLA_CUDA_VISIBLE_DEVICES:-0}"' in text
    assert 'CUDA_VISIBLE_DEVICES="${VLM_CUDA_VISIBLE_DEVICES:-0}"' in text
    assert 'MUJOCO_EGL_DEVICE_ID="${MUJOCO_EGL_DEVICE_ID:-0}"' in text
    assert 'git -C "${PACKAGE_GIT_DIR:-${PACK_DIR}}" rev-parse HEAD' in text
    assert 'git -C "${PACKAGE_GIT_DIR:-${PACK_DIR}}" status --short' in text
    assert "overlay_sha256=" in completed.stdout
    print("PASS counting single-GPU overlay contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
