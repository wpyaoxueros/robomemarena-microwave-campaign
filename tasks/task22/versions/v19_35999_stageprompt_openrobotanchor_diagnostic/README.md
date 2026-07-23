# Task22 v19: Open-Microwave Robot-Only Anchor Diagnostic

v19 keeps the v18 stage-prompt diagnostic and adds exactly one robot/gripper
pose reset when the scheduled prompt first becomes `open microwave`. It is a
diagnostic-only control for the original `35999` VLA under the pinned repaired
Task22 remote scorer. It does **not** count as VLM-autonomous success.

## Hypothesis

v18 completed the tomato sequence through `place tomato aside`, then remained
unable to open the microwave despite receiving the correct prompt. The likely
cause is the robot pose at this transition, rather than a missing VLA action
primitive. Reusing frame 0 of the matching Task22 `open_microwave` HDF gives
the robot and gripper the training-start pose for that primitive while leaving
the environment's object state untouched.

## What Changes

- One `INITIAL_SUBTASK_ANCHORS_JSON` rule applies on first entry to
  `open microwave`.
- The anchor calls only robot joint and gripper setters, then refreshes the
  observation. It never mutates a task object, microwave joint, goal, or
  scorer state.
- All VLA, norm, remote scorer, stage prompts, cookie EEF transition, and
  success checks remain the v18 values.

## Boundaries

- The original `35999` checkpoint and its built-in norm asset are retained.
- The remote scorer remains pinned to `8b7710924f862ab1c8dea69adada62e8c462de40`.
- No object anchor, goal override, completed-task VLM field, or fake stage is
  used.
- Prompts remain program-scheduled in this diagnostic. A later version must
  use VLM-owned prompts except for explicitly recorded missing-prompt rescue.
