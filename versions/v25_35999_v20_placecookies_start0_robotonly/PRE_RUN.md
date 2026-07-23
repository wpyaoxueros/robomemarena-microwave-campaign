# Task22 v25 Pre-Run Record

## Evidence

v24 reaches the `place cookies` scheduler transition after five official
stages, but it changes prompts based on EEF proximity alone and does not put
the robot at the training subtask's post-pick transport pose.

## Single Change From v24

Add a third initial anchor at first `place cookies` entry, using frame 0 of
the seed-104 training subtask. That frame begins with the gripper closed and
before the training trajectory's release keyframe. The anchor writes robot
joints and gripper only.

All evaluator/runtime files are copied byte-for-byte from v24. The VLA, VLM,
norm, scorer, prompt schedule, raw-VLM interval, prior robot anchors, and all
non-robot simulation state are unchanged.
