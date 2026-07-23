# Task23 v156 Incomplete Run Record

## Status

This is **not** a 20-episode result and must not be reported as one.

- Frozen code version: `a1f54ae`.
- Official scorer commit: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Intended matrix: five workers x four independent `seed=105` episodes.
- Valid completed episodes: four, all from worker 0 on `ACD1-1`.
- Valid stage-only successes: one of four.
- Eight other started episodes exited with return code `134` (`Aborted (core dumped)`) before an official summary or video existed. They are excluded.
- Four running worker jobs were then explicitly cancelled to prevent more repeated infrastructure failures. They are also excluded.

## Evidence

| worker | node | completed valid | return-code-134 aborts | final Slurm state |
| ---: | --- | ---: | ---: | --- |
| 0 | ACD1-1 | 4 | 0 | COMPLETED |
| 1 | ACD1-61 | 0 | 2 | CANCELLED by operator |
| 2 | ACD1-58 | 0 | 2 | CANCELLED by operator |
| 3 | ACD1-61 | 0 | 2 | CANCELLED by operator |
| 4 | ACD1-58 | 0 | 2 | CANCELLED by operator |

The shell line that failed in every abort was the VLM evaluator invocation:

```text
run_tasks2_26_sync_hold_eval.sh: line 244: ... Aborted (core dumped)
```

No `ORACLE_*` control was enabled and no object-moving anchor was part of this
run. These crashes are therefore an infrastructure/runtime exclusion, not a
model success or failure.

## Immutable External Artifacts

Raw artifacts remain under:

```text
/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_campaign_20260722/outputs/task23_v156_fixedseed105_20260722_073155_w*_w*
```

`VALID_EPISODES.tsv` stores the checksums for every valid official result.
Worker-run manifests and submission log checksums are retained in the raw
artifact directory. The successor v157 must start a fresh 20-episode matrix;
it must not append the aborted samples to a reported success rate.
