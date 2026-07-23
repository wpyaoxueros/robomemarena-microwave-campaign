# Task22 v16: Original 35999 With Soft VLM-Owned EEF Forward Gates

v16 keeps the same original `35999` VLA, built-in norm asset, Task22 VLM,
remote scorer, EEF targets, and all disabled oracle/object controls as v15.

## Single Behavior Change From v15

v15 required a held primitive to release only to the immediate task label. That
caused a static-observation loop because the VLM kept selecting `place tomato
aside` after a successful pickup instead of `pour first`.

v16 retains the EEF gate before a forward VLM transition, but sets
`STRICT_HOLD_RELEASE_NEXT=0`. Once the EEF hold is real, the next prompt is the
VLM's actual current candidate, even if it is not the adjacent label. The
runtime does not synthesize or replace that candidate.

## Invariants

- All `ORACLE_*` controls are zero.
- Completed-task prompt injection and stage locks are disabled.
- No object-moving anchor, object-region gate, lift gate, or gripper gate is
  enabled.
- Robot/gripper-only release anchors are preserved but only apply if a
  VLM-selected transition matches a declared anchor rule.
- Required current Task22 stages remain lift, pour one, pour two, tomato aside,
  open microwave, and cookies in microwave; close is audit-only.

This is an isolated timing experiment. Runtime artifacts remain ignored by Git
but each run snapshots the evaluator, scorer, configuration, logs, videos, and
checksums.
