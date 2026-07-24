# d9 Callback Compatibility Record

## Invalid attempts excluded from metrics

- Task1's first d9 launch ran zero valid episodes. The generic task2--26
  target JSON was incorrectly supplied to Task1's task-specific hold wrapper;
  it has no Task1 section. The original Task1 target file is
  `task1_subtask_end_poses_successindex_seed100_199.json` under the frozen
  inference runtime.
- Task3's first d9 launch ran zero valid episodes. The current remote base
  evaluator adds `task_id`, extra-pour and post-goal callback arguments and
  expects a diagnostics object, while the archived callback predates that
  interface.
- Task12 was not allowed to count because its VLA server stopped before the
  first episode when the submit account could not traverse the original norm
  cache. The matching norm SHA was verified separately; this is an access-path
  issue, not a changed norm value.

## Compatibility rule

The campaign does not replace historical rollout logic with the current remote
rollout. Instead, `eval_tasks2_26_sync_endpose_hold_d9_compat.py` is a frozen
copy of the historical wrapper with exactly one outer callback adapter:

1. accept the current remote callback parameters;
2. invoke the untouched archived hold/passage/prompt body;
3. return the current remote diagnostics shape, deriving `stage_success` from
   the current official stage scorer.

The adapter does not create prompts, alter VLM/VLA actions, modify completed
subtasks, or change the official stage scorer. All failed pre-adapter outputs
remain on disk for audit but are excluded from 20-episode reporting.
