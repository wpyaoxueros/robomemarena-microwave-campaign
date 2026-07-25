#!/usr/bin/env python3
"""Static guard for the d9 post-stage 200-step termination contract."""

from __future__ import annotations

import ast
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERIC_ADAPTER = ROOT / "evaluation_campaigns/latest_openhelix_d9f83ac_exact20_20260725/adapters/eval_tasks2_26_sync_endpose_hold_d9_compat.py"
TASK20_EVALUATOR = ROOT / "tasks/task20/evaluators/eval_tasks2_26_sync_endpose_hold_officialscore.py"
TASK20_RUNNER = ROOT / "tasks/task20/scripts/run_task20_v110.sh"
ARCHIVED_RUNNER = ROOT / "evaluation_campaigns/latest_openhelix_d9f83ac_exact20_20260725/scripts/run_archived_task_exact20.sh"


def require(path: Path, snippets: tuple[str, ...]) -> None:
    text = path.read_text(encoding="utf-8")
    ast.parse(text, filename=str(path)) if path.suffix == ".py" else None
    missing = [snippet for snippet in snippets if snippet not in text]
    if missing:
        raise AssertionError(f"{path}: missing contract snippets: {missing}")


def main() -> None:
    require(
        GENERIC_ADAPTER,
        (
            "post_goal_steps: int = 200",
            "post_goal_stage_reached_t",
            "official_stage._stage_success_from_stage_done",
            "[POST_GOAL_STAGE_REACHED]",
            "[POST_GOAL_STAGE_EXIT]",
            "(t - post_goal_stage_reached_t) >= post_goal_steps",
            "post_goal_steps=post_goal_steps",
        ),
    )
    require(
        TASK20_EVALUATOR,
        (
            "post_goal_steps: int = 200",
            "official_stage_success_with_runtime_contract",
            "[POST_GOAL_STAGE_REACHED]",
            "[POST_GOAL_STAGE_EXIT]",
            "(t - post_goal_stage_reached_t) >= post_goal_steps",
        ),
    )
    require(TASK20_RUNNER, ("export POST_GOAL_STEPS=${POST_GOAL_STEPS:-200}",))
    require(ARCHIVED_RUNNER, ("POST_GOAL_STEPS=${POST_GOAL_STEPS:-200}", "post_goal_steps=${POST_GOAL_STEPS}"))
    print("post-goal termination contract: PASS")


if __name__ == "__main__":
    main()
