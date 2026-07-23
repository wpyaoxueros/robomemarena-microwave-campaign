# Task22 v21: Pick-Cookies Robot-Anchor Diagnostic

v21 retains the v20 stage-prompt physical diagnostic, sparse raw-VLM logging,
and first-entry `open microwave` robot/gripper pose anchor. Its only new
intervention is a second robot/gripper-only anchor at first entry to
`pick cookies`. VLA inference and execution remain every 10 environment steps.

## Evidence Behind The Change

v20 physically completed five required remote stages, including open microwave.
After that point it executed `pick cookies` through the end of the rollout, but
never entered the 8 cm EEF target window (`cookies_pick_ready=0`). The isolated
hypothesis is that the carried-over arm pose, rather than the pick/place policy,
is preventing the final two-stage boundary from starting.

## Boundaries

- The original `35999` checkpoint and its built-in norm asset are retained.
- The remote scorer remains pinned to `8b7710924f862ab1c8dea69adada62e8c462de40`.
- VLA action replan remains 10 steps; raw VLM logging remains every 50 steps.
- Robot/gripper-only anchors apply once at `open microwave` and `pick cookies`.
- No object anchor, goal override, completed-task field, or fake stage is used.
- Prompts remain program-scheduled in this diagnostic. It is not reported as
  VLM-autonomous success; it only tests the physical boundary before a later
  partial VLM-owned rescue version.
