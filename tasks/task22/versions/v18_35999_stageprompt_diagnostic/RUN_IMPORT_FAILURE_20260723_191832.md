# Task22 v18 Import Failure Record

- Time: 2026-07-23 19:18:32 Asia/Shanghai
- Submit user: `zzhang510`
- Slurm job: `432671`
- Result: failed before environment reset or rollout.

## Failure

The correctly selected v18 evaluator ran from its version-local `runtime/`
directory. Its shared guard imports were resolved only relative to that
directory, so `microwave_debug` was unavailable. The failure happened after
the policy server became ready but before the evaluator could create an
episode.

## Corrective Change

The evaluator now explicitly adds the frozen package root to `sys.path` before
loading shared guards. A new inference-environment import smoke loads the full
evaluator before a GPU rollout is allowed.

## Integrity

Job `432671` created no episode, stage summary, or video. It is not an
evaluation result.
