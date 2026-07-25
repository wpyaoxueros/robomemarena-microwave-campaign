# POST_GOAL_STEPS=200 Correction

## Scope

This correction applies to the d9 archived hold adapter and the Task20 v110
microwave evaluator. The remote source is OpenHelix RoboMemArena commit
`d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.

## Defect

The previous adapter accepted `post_goal_steps`, logged the value, and then
called the archived rollout body without passing it through. The archived body
therefore continued until environment termination or `MAX_STEPS`. Task20 had
the same omission in its local evaluator.

## Correct Behavior

After the current d9 required-stage predicate first becomes true, the rollout
records `[POST_GOAL_STAGE_REACHED]`, continues the existing policy/hold path
for exactly 200 additional environment steps, then records
`[POST_GOAL_STAGE_EXIT]`. An environment `done` still exits immediately.

For Task20, the required-stage predicate also retains the existing
open-microwave EEF-hold audit. This does not create or inject a next prompt;
VLM prompt selection and all `ORACLE_*` flags are unchanged.

## Result Handling

Any run lacking both the explicit `post_goal_steps=200` manifest field and the
new runtime markers is pre-correction evidence only. It may be retained for
video/debug comparison, but it is excluded from the strict 20-episode table.

This excludes the interrupted Task3/Task14 pre-correction attempts and the
Task20 v110 batch started at `20260725_120537` (12 valid episodes, 7 successful
stage-only episodes). It does not delete their artifacts.

## Validation

Run before a new formal batch:

```bash
python3 evaluation_campaigns/latest_openhelix_d9f83ac_exact20_20260725/tests/test_post_goal_termination_contract.py
python3 -m py_compile \
  evaluation_campaigns/latest_openhelix_d9f83ac_exact20_20260725/adapters/eval_tasks2_26_sync_endpose_hold_d9_compat.py \
  tasks/task20/evaluators/eval_tasks2_26_sync_endpose_hold_officialscore.py
```

The one-episode smoke must snapshot the evaluator, record
`post_goal_steps=200`, and, when it reaches required stages, contain both
post-goal markers with an exit timestep exactly 200 after the reach timestep.
