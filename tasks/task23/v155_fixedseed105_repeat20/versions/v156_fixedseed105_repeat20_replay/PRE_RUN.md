# Task23 v156 Pre-Run Record

## Purpose

Independently repeat the frozen Task23 v155 fixed-seed experiment: twenty
separate invocations of `seed=105`, arranged as five workers with four episodes
each. This checks whether v155's `15/20` result remains reproducible without
changing its evaluator, VLM, VLA, norm, prompt, or scorer.

## Frozen contract

- Parent package commit: `76d895383827879df5684b57c17632553b6bb546`.
- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Each episode is `NUM_TRIALS=1`, `SEED=105`, `MAX_STEPS=2000`, and
  `REPLAN_STEPS=5`; using one 20-episode evaluator call is prohibited because
  that changes the environment seed between episodes.
- VLM generates prompts. All `ORACLE_*` controls are `0`; no object-moving
  anchor is allowed.
- Required stage-only success excludes optional `Close_Microwave`.
- Local model/data paths arrive only through an untracked private environment
  file and are never committed.

## Worker matrix

| worker | repeats | seed | port |
| ---: | ---: | ---: | ---: |
| 0 | 4 | 105 | 9740 |
| 1 | 4 | 105 | 9741 |
| 2 | 4 | 105 | 9742 |
| 3 | 4 | 105 | 9743 |
| 4 | 4 | 105 | 9744 |

## Result discipline

Raw manifests, scorer snapshots, logs, and videos remain in the external
artifact directory. Git stores only sanitized aggregate evidence and file
checksums after the job ends.
