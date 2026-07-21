# Task21 v122 Pre-Run Record

## Purpose

Run the already frozen Task21 v121 rollout unchanged on the two previously
successful seeds, `104` and `107`, before expanding to a wider seed set. This
is a reproduction check, not a new evaluator or model version.

## Frozen contract

- Parent package commit: `2432ebbd20170dc57c3b7bff894395b9a0d2937e`.
- Official RoboMemArena scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- VLA and VLM are supplied only through a private environment file; their
  local paths and weights are not committed.
- One independent episode per invocation, `MAX_STEPS=2000`, `REPLAN_STEPS=5`.
- All `ORACLE_*` controls remain `0`.
- VLM remains the only source of task prompts. EEF hold/release and
  robot-only anchors may control action timing but may not synthesize prompts
  or move object bodies.
- `Close_Microwave` is an audit-only stage; success is the required stage-only
  result produced by the pinned scorer.

## Run matrix

| label | seed | port | purpose |
| --- | ---: | ---: | --- |
| `seed104` | 104 | 9621 | Reproduce frozen success seed 104 |
| `seed107` | 107 | 9622 | Reproduce frozen success seed 107 |

## Result discipline

The raw run directory is external to Git. After each invocation, add a
sanitized result record containing scorer commit, frozen-code hash, status,
stage/goal metrics, and raw-artifact checksum. Do not commit model paths,
checkpoint files, HDF data, videos, or the private environment file.
