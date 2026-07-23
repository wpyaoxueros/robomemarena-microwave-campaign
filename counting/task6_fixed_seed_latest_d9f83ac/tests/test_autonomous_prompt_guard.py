import unittest

from evaluators.autonomous_prompt_guard import AutonomousPromptGuard, PromptPollSchedule


TASK7_LABELS = [
    "pick tomato sauce",
    "pour tomato sauce into frypan 1st",
    "pour tomato sauce into frypan 2nd",
    "place tomato sauce bowl drainer",
]

TASK6_LABELS = [
    "pick tomato sauce",
    "pour tomato sauce over cookies 1st",
    "pour tomato sauce over cookies 2nd",
    "place tomato sauce bowl drainer",
]


class AutonomousPromptGuardTest(unittest.TestCase):
    def test_task7_blocks_early_forward_switches_and_regressions(self):
        guard = AutonomousPromptGuard(task_id=7, primitive_labels=TASK7_LABELS)

        self.assertEqual(guard.filter_prompt("pick tomato sauce").prompt, TASK7_LABELS[0])
        early = guard.filter_prompt("pour tomato sauce into frypan 1st")
        self.assertEqual(early.prompt, TASK7_LABELS[0])
        self.assertEqual(early.reason, "required_stage_incomplete")

        guard.observe_stage(0, "01_Lift_Tomato_Sauce")
        self.assertEqual(guard.filter_prompt(TASK7_LABELS[1]).prompt, TASK7_LABELS[1])

        regression = guard.filter_prompt(TASK7_LABELS[0])
        self.assertEqual(regression.prompt, TASK7_LABELS[1])
        self.assertEqual(regression.reason, "regression")

        early_place = guard.filter_prompt(TASK7_LABELS[3])
        self.assertEqual(early_place.prompt, TASK7_LABELS[1])
        self.assertEqual(early_place.reason, "required_stage_incomplete")

    def test_task7_accepts_only_vlm_emitted_prompts_after_stage_gates(self):
        guard = AutonomousPromptGuard(task_id=7, primitive_labels=TASK7_LABELS)
        guard.filter_prompt(TASK7_LABELS[0])
        guard.observe_stage(0, "01_Lift_Tomato_Sauce")
        guard.filter_prompt(TASK7_LABELS[1])

        guard.observe_stage(1, "02_Pour_One")
        self.assertEqual(guard.filter_prompt(TASK7_LABELS[2]).prompt, TASK7_LABELS[2])
        self.assertEqual(guard.filter_prompt(TASK7_LABELS[3]).prompt, TASK7_LABELS[2])

        guard.observe_stage(2, "03_Pour_Two")
        accepted = guard.filter_prompt(TASK7_LABELS[3])
        self.assertEqual(accepted.prompt, TASK7_LABELS[3])
        self.assertEqual(accepted.reason, "accepted")

    def test_task7_stage_count_marks_pour_two_as_third_required_stage(self):
        guard = AutonomousPromptGuard(task_id=7, primitive_labels=TASK7_LABELS)
        guard.observe_stage(0, "01_Lift_Tomato_Sauce")
        guard.observe_stage(1, "02_Pour_One")
        guard.observe_stage(2, "03_Pour_Two")
        self.assertEqual(guard.stage_count, 3)

    def test_task6_uses_the_same_guard_without_prompt_injection(self):
        guard = AutonomousPromptGuard(task_id=6, primitive_labels=TASK6_LABELS)
        guard.filter_prompt(TASK6_LABELS[0])
        self.assertEqual(guard.filter_prompt(TASK6_LABELS[1]).reason, "required_stage_incomplete")
        guard.observe_stage(0, "01_Lift_Tomato_Sauce")
        self.assertEqual(guard.filter_prompt(TASK6_LABELS[1]).prompt, TASK6_LABELS[1])
        guard.observe_stage(1, "02_Pour_One")
        self.assertEqual(guard.filter_prompt(TASK6_LABELS[2]).prompt, TASK6_LABELS[2])

    def test_prompt_poll_schedule_reuses_until_interval(self):
        schedule = PromptPollSchedule(interval=25)

        self.assertTrue(schedule.should_infer(0))
        schedule.mark_inferred(0)
        self.assertFalse(schedule.should_infer(5))
        self.assertFalse(schedule.should_infer(20))
        self.assertTrue(schedule.should_infer(25))

    def test_prompt_poll_schedule_forces_inference_after_stage(self):
        schedule = PromptPollSchedule(interval=25)
        schedule.mark_inferred(0)
        schedule.force_next()

        self.assertTrue(schedule.should_infer(15))
        schedule.mark_inferred(15)
        self.assertFalse(schedule.should_infer(35))
        self.assertTrue(schedule.should_infer(40))


if __name__ == "__main__":
    unittest.main()
