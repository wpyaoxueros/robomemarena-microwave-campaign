# Task22 v14: Remote Stages With Original 35999 VLA

This is the Task22 baseline requested after the legacy 2999 replay was
cancelled. It keeps the v12 remote Task22 stage contract and rollout behavior,
but locks the original 35999 VLA and matching original norm in a private input
file.

## Fixed Contract

- Remote scorer commit: `8b7710924f862ab1c8dea69adada62e8c462de40`.
- Required stages: two pours, tomato aside, open microwave, and cookies in
  microwave. Closing is audit-only.
- Original 35999 VLA plus its matching original norm, verified before launch.
- VLM controls the prompt. Every `ORACLE_*` flag is zero; completed-task
  prompt injection and object anchors are disabled.
- The remote stage preflight runs inside the inference virtual environment,
  because the borrowed account's shell `python3` does not provide numpy.

This is a current-stage scorer run, not a legacy scorer replay.
