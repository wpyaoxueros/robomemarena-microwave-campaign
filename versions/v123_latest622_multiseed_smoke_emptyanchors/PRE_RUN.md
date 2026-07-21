# Task21 v123 Pre-Run Record

## Purpose

Repeat the v122 seed-104 and seed-107 reproduction gate after correcting only
the empty release-anchor JSON representation.

## Single Controlled Difference from v122

v122 materialized the intended zero-anchor policy as `[]`, which violates the
evaluator's release-anchor JSON contract and fails before the environment
steps. v123 supplies the equivalent valid representation:

```json
{"tasks": {}}
```

This means **no release anchors**. It does not add an anchor or alter any
rollout behavior after startup.

## Frozen Contract

- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- VLA and VLM are supplied by an untracked private environment file.
- One independent episode per invocation; seeds `104` and `107`.
- `MAX_STEPS=2000`, `REPLAN_STEPS=5`.
- All `ORACLE_*` controls are `0`; VLM remains the prompt source.
- EEF timing assistance may wait or release but cannot write the next prompt.
- Required-stage-only result, with `Close_Microwave` audit-only.

## Publication Rule

This directory and its code are committed and pushed before submission. The
outcome will be recorded as a separate immutable result commit.
