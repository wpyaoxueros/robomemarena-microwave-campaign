# Task22 v17 Pre-Run Record

## Evidence From v16

v16 showed the desired first behavior: the original 35999 policy completed the
lift stage and reached a real `pick tomato` EEF hold before the VLM-selected
`place tomato aside` transition. It then proved a scope bug: later primitives
also entered end-pose holds because the complete target file remained active.

## Single Logical Change

Replace the full hold-target file with
`config/task22_pick_tomato_only_endpose_targets.json`. The new file contains
exactly the source-audited `pick tomato` EEF target and no other Task22 target.

The forward gate is correspondingly scoped to `pick tomato`. After that first
hold, all later prompt selection and action execution remain VLM-owned.

## Invariants

- Same original 35999 weights and built-in norm asset.
- Same Task22 VLM weights and remote scorer commit.
- `STRICT_HOLD_RELEASE_NEXT=0`, so release uses the VLM's actual candidate.
- All oracle, completed, object, lift, gripper, and stage-lock controls remain
  disabled.
