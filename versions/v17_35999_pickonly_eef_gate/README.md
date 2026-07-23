# Task22 v17: Original 35999 With Pick-Only VLM-Owned EEF Gate

v17 retains the original `35999` VLA, its checkpoint-owned norm asset, the
same Task22 VLM, and the repaired remote Task22 scorer from v16.

## Root-Cause Fix

The prior variants used the full end-pose target file. Although their forward
transition list mentioned selected prompts, every target in that file could
still start a hold. A later `place tomato aside` hold froze the VLM again.

v17 uses a new, source-audited target JSON containing only `pick tomato`.
This means:

1. The first VLM-selected pickup cannot be abandoned before a real EEF hold.
2. Once that hold releases to a VLM-generated candidate, all later VLM prompts
   run without end-pose hold, stage lock, or runtime-written next prompt.
3. The remote scorer still evaluates the real two pours, tomato placement,
   microwave open, and cookies-in-microwave stages. Closing remains optional.

## Disabled Controls

- All `ORACLE_*` prompt controls.
- Completed-task prompt injection and official-stage prompt updates.
- Object-moving anchors, object-region gates, lift gates, gripper gates, and
  stage locks.

The two robot/gripper-only release anchors remain available but apply only to a
matching VLM-selected transition; neither moves an object.
