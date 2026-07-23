# Task14 v1 Pre-Run Record

## Frozen Contract

- RoboMemArena scorer commit: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Seeds 104--123; `NUM_TRIALS=20`; `MAX_STEPS=2200`; `REPLAN_STEPS=10`.
- VLM chooses prompts; every `ORACLE_*` prompt-injection control is zero.
- EEF hold/release, regression guard, completed-subtask context, pick gripper
  gate and object-lift gate match the recorded baseline.
- No release anchor is configured.

Raw output remains outside Git. A subsequent Task14 variant must be created as
a new directory under `task14/versions/`, committed and pushed before launch.
