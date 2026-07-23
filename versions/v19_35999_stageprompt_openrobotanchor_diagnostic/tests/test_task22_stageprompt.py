from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "runtime"))

from task22_stageprompt import load_pick_cookies_target, prompt_for_stage


def test_stage_prompt_order() -> None:
    assert [prompt_for_stage(idx, False) for idx in range(5)] == [
        "pick tomato",
        "pour first",
        "pour second",
        "place tomato aside",
        "open microwave",
    ]
    assert prompt_for_stage(5, False) == "pick cookies"
    assert prompt_for_stage(5, True) == "place cookies"
    assert prompt_for_stage(6, True) == "close microwave"


def test_pick_cookies_target() -> None:
    target = load_pick_cookies_target(ROOT.parents[1] / "config" / "tasks2_26_endpose_targets_seed100_199.json")
    assert target.position.shape == (3,)
    assert target.p95 > 0.0


if __name__ == "__main__":
    test_stage_prompt_order()
    test_pick_cookies_target()
    print("TASK22_STAGEPROMPT_UNIT_OK")
