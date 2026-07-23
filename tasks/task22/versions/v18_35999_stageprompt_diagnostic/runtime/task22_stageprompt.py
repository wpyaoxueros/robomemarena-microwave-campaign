"""Prompt schedule used only by the Task22 VLA capability diagnostic."""

from __future__ import annotations

from dataclasses import dataclass
import json
from pathlib import Path

import numpy as np


STAGE_PROMPTS = (
    "pick tomato",
    "pour first",
    "pour second",
    "place tomato aside",
    "open microwave",
)


def prompt_for_stage(official_stage_idx: int, cookies_pick_ready: bool) -> str:
    """Return the diagnostic VLA prompt for the next uncompleted stage."""
    if official_stage_idx < 0:
        raise ValueError(f"official_stage_idx must be non-negative, got {official_stage_idx}")
    if official_stage_idx < len(STAGE_PROMPTS):
        return STAGE_PROMPTS[official_stage_idx]
    if official_stage_idx == len(STAGE_PROMPTS):
        return "place cookies" if cookies_pick_ready else "pick cookies"
    return "close microwave"


@dataclass(frozen=True)
class PickCookiesTarget:
    position: np.ndarray
    p95: float


def load_pick_cookies_target(path: Path) -> PickCookiesTarget:
    payload = json.loads(path.read_text(encoding="utf-8"))
    raw = payload["tasks"]["22"]["subtasks"]["pick cookies"]
    position = np.asarray(raw["target_ee_pos"], dtype=np.float64).reshape(-1)
    if position.size != 3:
        raise ValueError("Task22 pick-cookies target must have exactly three coordinates")
    return PickCookiesTarget(position=position, p95=float(raw.get("pos_dist_p95", 0.0)))
