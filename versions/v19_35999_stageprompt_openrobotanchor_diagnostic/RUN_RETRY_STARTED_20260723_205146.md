# Task22 v19 Retry Started On Alternate Node

- Started: `2026-07-23T20:51:46+08:00`
- Submit Unix user: `zzhang510`
- Slurm job: `432849`
- Allocation: `ACD1-13`, 2 GPUs
- Run ID: `task22_v19_35999_stageprompt_openrobotanchor_seed104_20260723_205146`
- Package commit at launch: `045be85`
- Remote scorer commit: `8b7710924f862ab1c8dea69adada62e8c462de40`

## Controlled Difference From The Aborted Attempt

The launch excludes `ACD1-61`, where the otherwise identical v19 attempt was
about twenty times slower per chunk and ended with SIGABRT before its anchor.
The retry was allocated on `ACD1-13`, the node used by the valid v18 control.

No VLA/VLM, prompt schedule, robot-only anchor, norm asset, scorer, BDDL, seed,
replan interval, or success rule changed. The retry additionally writes a GPU
inventory file inside its ignored output directory for audit.
