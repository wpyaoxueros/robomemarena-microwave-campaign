# Task22 v22 Pre-Run Record

## Evidence From v21

v21 retained v20's five-stage trajectory and added the seed-104
`pick cookies` robot/gripper-only anchor. It reached the final place-cookies
segment but the VLM process aborted before the rollout finalizer wrote an
official score. The abort happened after roughly 51 raw VLM calls.

## Single Change

Keep every v21 policy, VLA replan, prompt schedule, anchor, scorer, weight,
and norm setting. Change only raw VLM sampling:

- v21: every 50 environment steps
- v22: every 150 environment steps

`smoke_task22_initial_state.py` separately records whether repeated seed-104
resets produce identical physical and image observations using the exact
remote evaluator environment construction.

## Interpretation Rule

A six-of-six result would establish that this physical path survives fewer VLM
calls. It remains a stage-scheduled capability diagnostic, not a claim of
VLM-owned prompt switching.
