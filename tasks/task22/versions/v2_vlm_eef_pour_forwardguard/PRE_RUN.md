# Task22 v2 Pre-Run Record

## Purpose

Test a VLM-autonomous counting/pour rollout under the latest RoboMemArena
stage scorer.  The target is all three required stages: lift tomato sauce,
first pour, and second pour.

## Single Behavioral Change From v1

v1 accepted every VLM prompt immediately.  v2 introduces an EEF-only timing
rule for `pick tomato` and `pour first`:

1. The VLM still supplies every prompt.
2. If it proposes a later primitive before the current EEF target has held,
   rollout keeps the current VLM prompt.
3. Once the EEF hold begins, release requires a VLM-provided later prompt.
4. After that release, the evaluator may restore only robot joints/gripper to
   the corresponding training subtask frame.  It never moves tomato sauce,
   cookies, or any other object.

No stage-prompt override, oracle prompt, completed-subtask prompt, or object
anchor is enabled.

## Frozen Contract

- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- `MAX_STEPS=2000`, `REPLAN_STEPS=5`, one seed per smoke.
- `ORACLE_* = 0` and `VLM_COMPLETED_SUBTASKS_MODE=off`.
- Stage-only success requires all three Task22 pour stages.
- Checkpoints and machine-specific paths are supplied only through an ignored
  private environment file.
