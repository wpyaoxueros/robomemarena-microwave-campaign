#!/usr/bin/env python3
"""Contract tests for the canonical owner-side experiment evidence root."""

from __future__ import annotations

import getpass
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
TOOL = REPO_ROOT / "scripts" / "central_evidence.py"


class CentralEvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name) / "evidence"
        self.assets = Path(self.tmp.name) / "assets"
        self.assets.mkdir()
        self.asset_paths: dict[str, Path] = {}
        for name in (
            "vla_checkpoint",
            "vla_norm",
            "vlm_checkpoint",
            "evaluator_path",
            "scorer_path",
            "entrypoint",
        ):
            path = self.assets / name
            path.write_text(f"{name}\n", encoding="utf-8")
            self.asset_paths[name] = path

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def manifest(self, **overrides: object) -> Path:
        payload: dict[str, object] = {
            "run_id": "task20_demo",
            "campaign_id": "central_evidence_test",
            "task_id": 20,
            "submit_user": getpass.getuser(),
            "seed_spec": "106",
            "policy_seed": 0,
            "episode_target": 1,
            "post_goal_steps": 200,
            "topology": "single_gpu_colocated",
            "oracle_prompt_injection": False,
            "object_anchor": False,
            "fallback_used": False,
            "scorer_commit": "62214036103ee8d5fef9b475dd8b344b6e2cfc03",
            "evaluator_commit": "test-evaluator-commit",
            "launch_command": ["bash", "run_task20.sh"],
            "vla_checkpoint": str(self.asset_paths["vla_checkpoint"]),
            "vla_norm": str(self.asset_paths["vla_norm"]),
            "vlm_checkpoint": str(self.asset_paths["vlm_checkpoint"]),
            "evaluator_path": str(self.asset_paths["evaluator_path"]),
            "scorer_path": str(self.asset_paths["scorer_path"]),
            "entrypoint": str(self.asset_paths["entrypoint"]),
        }
        payload.update(overrides)
        source = Path(self.tmp.name) / f"{payload['run_id']}.json"
        source.write_text(json.dumps(payload), encoding="utf-8")
        return source

    def run_tool(self, *args: str) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["CENTRAL_EVIDENCE_ROOT"] = str(self.root)
        return subprocess.run(
            [sys.executable, str(TOOL), *args],
            cwd=REPO_ROOT,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_init_writes_manifest_and_registry(self) -> None:
        result = self.run_tool("init", "--manifest", str(self.manifest()))
        self.assertEqual(result.returncode, 0, result.stderr)

        run_dir = self.root / "runs" / "task20_demo"
        manifest = json.loads((run_dir / "run_manifest.json").read_text())
        self.assertEqual(manifest["status"], "prepared")
        self.assertEqual(Path(manifest["run_dir"]), run_dir)
        self.assertTrue((run_dir / "logs").is_dir())
        self.assertTrue((run_dir / "videos").is_dir())

        registry_lines = (self.root / "RUN_REGISTRY.jsonl").read_text().splitlines()
        self.assertEqual(len(registry_lines), 1)
        self.assertEqual(json.loads(registry_lines[0])["status"], "prepared")
        self.assertIn("task20_demo", (self.root / "RUN_REGISTRY.tsv").read_text())

    def test_init_rejects_unreadable_asset(self) -> None:
        missing = Path(self.tmp.name) / "missing_checkpoint"
        result = self.run_tool(
            "init", "--manifest", str(self.manifest(vla_checkpoint=str(missing)))
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unreadable asset: vla_checkpoint", result.stderr)
        self.assertFalse((self.root / "runs").exists())

    def test_init_rejects_different_submit_user(self) -> None:
        result = self.run_tool(
            "init", "--manifest", str(self.manifest(submit_user="not_the_current_user"))
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("submit_user", result.stderr)

    def test_init_rejects_fallback_assets(self) -> None:
        result = self.run_tool(
            "init", "--manifest", str(self.manifest(fallback_used=True))
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("fallback_used", result.stderr)

    def test_transition_appends_completed_event(self) -> None:
        init = self.run_tool("init", "--manifest", str(self.manifest()))
        self.assertEqual(init.returncode, 0, init.stderr)
        result = self.run_tool(
            "transition",
            "--run-id",
            "task20_demo",
            "--status",
            "completed",
            "--episodes-completed",
            "1",
            "--stage-successes",
            "1",
            "--goal-successes",
            "1",
        )
        self.assertEqual(result.returncode, 0, result.stderr)

        events = [
            json.loads(line)
            for line in (self.root / "RUN_REGISTRY.jsonl").read_text().splitlines()
        ]
        self.assertEqual(events[-1]["status"], "completed")
        manifest = json.loads(
            (self.root / "runs" / "task20_demo" / "run_manifest.json").read_text()
        )
        self.assertEqual(manifest["episodes_completed"], 1)
        self.assertEqual(manifest["stage_successes"], 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
