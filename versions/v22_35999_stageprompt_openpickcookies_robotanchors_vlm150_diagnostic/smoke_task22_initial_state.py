#!/usr/bin/env python3
"""Record whether Task22 starts identically for repeated seed-104 resets.

This deliberately uses the same evaluator import, seed helper, BDDL resolver,
camera patch, and environment constructor as the rollout.  It does not load a
policy or take an action.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any

import numpy as np


EXPECTED_REMOTE_COMMIT = "8b7710924f862ab1c8dea69adada62e8c462de40"


def _digest(value: Any) -> dict[str, Any]:
    array = np.ascontiguousarray(np.asarray(value))
    return {
        "dtype": str(array.dtype),
        "shape": list(array.shape),
        "sha256": hashlib.sha256(array.tobytes()).hexdigest(),
    }


def _capture(env: Any, base: Any, seed: int) -> dict[str, Any]:
    base._seed_everywhere(seed)
    env.seed(seed)
    obs = env.reset()

    physical = {
        "qpos": _digest(env.sim.data.qpos),
        "qvel": _digest(env.sim.data.qvel),
        "body_xpos": _digest(env.sim.data.body_xpos),
        "body_xquat": _digest(env.sim.data.body_xquat),
        "site_xpos": _digest(env.sim.data.site_xpos),
    }
    observation = {
        str(key): _digest(value)
        for key, value in sorted(obs.items())
        if isinstance(value, np.ndarray)
    }
    image_keys = [
        key
        for key, value in obs.items()
        if isinstance(value, np.ndarray) and value.ndim >= 3
    ]
    return {
        "physical": physical,
        "observation": observation,
        "image_keys": sorted(image_keys),
    }


def _equal_section(left: dict[str, Any], right: dict[str, Any], section: str) -> bool:
    return left[section] == right[section]


def _load_base(remote_root: Path, libero_root: Path) -> Any:
    reference_dir = remote_root / "evaluation_benchmark" / "reference_evaluation" / "tasks2_26_vlm5_reference"
    script_dir = remote_root / "evaluation_benchmark" / "scripts"
    runtime_dir = remote_root / "evaluation_benchmark" / "openpi_minimal_runtime"
    # Keep the remote scripts ahead of the runtime shim, matching the evaluator.
    for path in reversed((reference_dir, script_dir, runtime_dir, libero_root, libero_root.parent)):
        path_text = str(path)
        if path_text not in sys.path:
            sys.path.insert(0, path_text)
    os.environ.setdefault("PYOPENGL_PLATFORM", "egl")
    os.environ.setdefault("MUJOCO_GL", "egl")
    import eval_tasks2_26_vlm_vla as base

    return base


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--remote-root", required=True, type=Path)
    parser.add_argument("--libero-root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--seed", default=104, type=int)
    args = parser.parse_args()

    remote_root = args.remote_root.resolve()
    actual_commit = subprocess.check_output(
        ["git", "-C", str(remote_root), "rev-parse", "HEAD"], text=True
    ).strip()
    if actual_commit != EXPECTED_REMOTE_COMMIT:
        raise SystemExit(
            f"remote commit mismatch: expected={EXPECTED_REMOTE_COMMIT} actual={actual_commit}"
        )

    os.environ["ROBOMEMARENA_REMOTE_ROOT_OVERRIDE"] = str(remote_root)
    os.environ["TARGET_LIBERO_PATH"] = str(args.libero_root.resolve())
    base = _load_base(remote_root, args.libero_root.resolve())
    base.patch_env_resolution()
    bddl_path = base.ec._resolve_bddl_path(22)

    def build_env() -> Any:
        return base.ec._get_env_class()(
            bddl_file_name=str(bddl_path),
            camera_heights=480,
            camera_widths=640,
            ignore_done=True,
            reward_shaping=True,
            control_freq=20,
            initialization_noise=None,
        )

    env = build_env()
    first = _capture(env, base, args.seed)
    second_same_env = _capture(env, base, args.seed)
    env.close()

    fresh_env = build_env()
    fresh = _capture(fresh_env, base, args.seed)
    fresh_env.close()

    report = {
        "remote_commit": actual_commit,
        "seed": args.seed,
        "bddl": str(bddl_path),
        "same_env_physical_equal": _equal_section(first, second_same_env, "physical"),
        "same_env_observation_equal": _equal_section(first, second_same_env, "observation"),
        "fresh_env_physical_equal": _equal_section(first, fresh, "physical"),
        "fresh_env_observation_equal": _equal_section(first, fresh, "observation"),
        "first": first,
        "second_same_env": second_same_env,
        "fresh": fresh,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({key: report[key] for key in report if key.endswith("_equal")}, sort_keys=True))
    if not report["same_env_physical_equal"]:
        raise SystemExit("same-environment physical state differs after identical seed/reset")


if __name__ == "__main__":
    main()
