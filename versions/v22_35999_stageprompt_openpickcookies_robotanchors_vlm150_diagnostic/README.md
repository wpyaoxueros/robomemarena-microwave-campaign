# Task22 v22: Raw-VLM-150 Pick-Cookies Robot-Anchor Diagnostic

v22 retains v21's stage-prompt physical diagnostic and both robot/gripper-only
anchors. Its sole rollout behavior change is raw VLM sampling from every 50
environment steps to every 150 steps. VLA inference and execution remain every
10 environment steps.

## Evidence Behind The Change

v21 reached the `pick cookies` EEF-ready boundary after both robot-only anchors,
then ran through the final placement segment before the VLM process aborted
around 51 raw VLM calls. The isolated hypothesis is that fewer raw VLM calls
avoid that process instability without changing the policy, anchors, scorer,
or prompt schedule.

## Boundaries

- The original `35999` checkpoint and its built-in norm asset are retained.
- The remote scorer remains pinned to `8b7710924f862ab1c8dea69adada62e8c462de40`.
- VLA action replan remains 10 steps; raw VLM logging is every 150 steps.
- Robot/gripper-only anchors apply once at `open microwave` and `pick cookies`.
- No object anchor, goal override, completed-task field, or fake stage is used.
- Prompts remain program-scheduled in this diagnostic. It is not reported as
  VLM-autonomous success; it only tests the physical boundary before a later
  partial VLM-owned rescue version.
