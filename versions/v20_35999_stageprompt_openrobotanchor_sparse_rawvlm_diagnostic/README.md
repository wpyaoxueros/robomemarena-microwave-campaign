# Task22 v20: Sparse-Raw-VLM Open-Microwave Anchor Diagnostic

v20 retains the v19 stage-prompt physical diagnostic and its one robot/gripper
pose anchor at the first `open microwave` entry. It reduces only raw VLM
*observation logging* to once per 50 environment steps. VLA inference and
execution remain every 10 steps. It is diagnostic-only and does **not** count
as VLM-autonomous success.

## Evidence Behind The Change

Two v19 attempts using identical VLA/VLM/scorer settings ended with SIGABRT
near the fiftieth raw VLM generation, before the open-microwave anchor could
run. In the stage-prompt diagnostic, raw VLM output is recorded for analysis
but never supplies the VLA action prompt.

## Boundaries

- The original `35999` checkpoint and its built-in norm asset are retained.
- The remote scorer remains pinned to `8b7710924f862ab1c8dea69adada62e8c462de40`.
- VLA action replan remains 10 steps; only raw VLM logging has interval 50.
- One robot/gripper-only anchor applies on first entry to `open microwave`.
- No object anchor, goal override, completed-task field, or fake stage is used.
- Prompts remain program-scheduled in this diagnostic; a later partial-rescue
  version must earn VLM-owned prompt credit separately.
