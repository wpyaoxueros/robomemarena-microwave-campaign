# Task21 v125 Pre-Run Record

## Purpose

Test one measured boundary adjustment for Task21 seed104.

## Single controlled difference from v124

`pick chocolate` EEF hold tolerance changes from `0.045 m` to `0.050 m`.
The v124 seed104 trajectory reached `0.04838 m` and the VLM was already
requesting `place chocolate`, but release stayed blocked because it missed the
old threshold by `0.00338 m`.

Every other v121 tolerance and target remains byte-for-byte represented by the
same values as v124.  The VLM/VLA inputs, scorer, seed, prompt rules, anchors,
and all `ORACLE_*` settings are unchanged.

## Frozen contract

- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- One episode, seed `104`, `MAX_STEPS=2000`, `REPLAN_STEPS=5`.
- VLM supplies prompts; all `ORACLE_*` prompt-injection controls remain `0`.
- `completed_struct` is context only and cannot write the next prompt.
- Stage-only scoring; `Close_Microwave` remains optional.

This version is committed and pushed before submission.  Its raw output remains
external and its result record will include artifact checksums.
