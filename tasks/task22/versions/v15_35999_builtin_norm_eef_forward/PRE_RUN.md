# Task22 v15 Pre-Run Record

## Hypothesis

The v14 failure was caused by prompt replacement timing, not by a wrong VLA
normalization value: the old external norm and the checkpoint asset have the
same SHA-256. At step 300, `pick tomato` had one EEF near-target sample but the
second sample was preempted by VLM output. Holding the current VLM prompt until
the EEF hold begins should allow the VLA to finish the active primitive.

## Single Behavior Change

Enable the existing EEF-only forward gate for the ordered Task22 primitives.
The gate retains the current VLM prompt when a later VLM candidate arrives
before the current prompt has an EEF hold. It does not infer, inject, or
replace any next prompt. After hold, strict release still requires the VLM to
emit the immediate next primitive.

## Controls That Remain Disabled

- Every `ORACLE_*` prompt control.
- Completed-subtask prompt injection and official-stage prompt updates.
- Object-moving anchors, object-region gates, lift gates, and gripper gates.
- Stage-lock and completed-stage forward logic.

## Validation Before GPU Rollout

1. Verify the original 35999 weight and built-in norm fingerprints.
2. Verify the repaired Task22 remote scorer contract in the inference virtual
   environment.
3. Run fresh 1-GPU and 2-GPU allocation probes from `zzhang510`.
4. Run one episode only, then inspect stage JSON, prompt trace, EEF hold/release
   logs, server norm loading, and videos before expanding the run.
