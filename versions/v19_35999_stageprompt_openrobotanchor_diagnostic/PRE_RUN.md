# Task22 v19 Pre-Run Record

## Evidence From v18

With the original `35999` VLA and correct stage prompts, v18 physically
completed lift tomato, both pours, and place tomato aside. It then scheduled
`open microwave` through the remaining rollout but never opened the door.

## Hypothesis

The `place tomato aside -> open microwave` robot pose is the active physical
boundary. Applying the matching training HDF's robot/gripper frame 0 only at
the first `open microwave` entry should let the unchanged policy execute the
opening primitive.

## Single Change

v19 adds one validated robot-only initial-subtask anchor. It does not move
objects, modify microwave state, alter the scorer, replace the VLA/norm, or
change the stage-prompt schedule.

## Non-Goal

This run remains a fully scheduled capability diagnostic. A positive result is
evidence for the boundary hypothesis, not VLM-autonomous success.
