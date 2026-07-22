# Task21 v124 Pre-Run Record

## Purpose

Repeat the seed-104 and seed-107 reproduction gate after preserving the
frozen v121 min-hold configuration through the nested historical runner.

## Controlled Differences

1. v123's valid zero-anchor representation `{"tasks": {}}` is retained.
2. The nested v108 runner now honors its caller-provided
   `task21_v121_min_hold_steps.json` instead of overwriting it with a missing
   legacy filename.

No numeric hold setting, VLM/VLA input, prompt, scorer, seed, or anchor rule
is changed. The zero-anchor policy remains zero anchors.

## Frozen Contract

- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- One independent episode per invocation for seeds `104` and `107`.
- `MAX_STEPS=2000`, `REPLAN_STEPS=5`.
- All `ORACLE_*` controls are `0`; prompts originate from the VLM.
- Required-stage-only result; `Close_Microwave` remains audit-only.

This version is committed and pushed before submission. Raw artifacts remain
external; its result record will include checksums and stage outcomes.
