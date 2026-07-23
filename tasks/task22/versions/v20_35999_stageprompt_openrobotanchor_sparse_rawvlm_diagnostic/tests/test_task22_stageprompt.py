from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "runtime"))

from task22_stageprompt import load_pick_cookies_target, prompt_for_stage, should_refresh_raw_vlm


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


def test_sparse_raw_vlm_schedule() -> None:
    assert should_refresh_raw_vlm(0, None, 50)
    assert not should_refresh_raw_vlm(10, 0, 50)
    assert not should_refresh_raw_vlm(40, 0, 50)
    assert should_refresh_raw_vlm(50, 0, 50)


if __name__ == "__main__":
    test_stage_prompt_order()
    test_pick_cookies_target()
    test_sparse_raw_vlm_schedule()
    print("TASK22_STAGEPROMPT_UNIT_OK")
