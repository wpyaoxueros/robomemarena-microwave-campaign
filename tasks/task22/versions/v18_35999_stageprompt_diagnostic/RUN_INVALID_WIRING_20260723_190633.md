# Task22 v18 Invalid Wiring Record

- Time: 2026-07-23 19:06:33 Asia/Shanghai
- Submit user: `zzhang510`
- Slurm job: `432604`
- Exit: cancelled after wiring diagnosis; no valid episode result.

## What Was Wrong

The shared launcher unconditionally overwrote `EVAL_PY` with the package-wide
official-score wrapper. As a result, the v18 stage-prompt evaluator was not the
process executed by the job. The output shell snapshot proves the active path
was the shared evaluator, even though the v18 diagnostic environment variables
were present.

## Consequence

The job loaded the VLA and VLM but did not run the intended diagnostic. It
produced no episode summary, video, or usable success/failure signal and must
not be included in any metric.

## Corrective Change

v18 now owns a frozen launcher that accepts only its explicitly supplied
evaluator path. `verify_runtime_wiring.sh` checks the active evaluator path
without allocating GPUs before every future v18 launch.
