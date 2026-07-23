# RoboMemArena Task24 v123 Autonomous Reproduction

This is a sanitized reproduction package for the Task24 v123 EEF-only,
robot-only-anchor rollout. It is pinned to RoboMemArena scorer commit
`62214036103ee8d5fef9b475dd8b344b6e2cfc03` and aborts if
`task2_26_reference_stage.py` is unavailable.

The VLM provides all prompts. All `ORACLE_*` controls are zero. EEF
hold/release, completed-stage context, and robot-only release anchors can
control timing; they cannot generate prompts or move objects. `Close_Microwave`
is audit-only under this package's stage-only success convention.

No checkpoint files, local checkpoint paths, raw task data, or videos are
committed. Use `paths.example.env` as a private local interface.
