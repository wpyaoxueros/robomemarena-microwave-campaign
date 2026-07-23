# Task23 v157 Pre-Run Record

## Purpose

Repeat the frozen Task23 v155 experiment as twenty independent `seed=105`
episodes on the only node that completed all four valid v156 episodes: ACD1-1.

## Only Change From v156

This version changes **scheduling only**:

- one serial worker instead of five concurrent workers;
- request two GPUs from `ACD1-1`;
- execute twenty separate `NUM_TRIALS=1` calls with `SEED=105`;
- stop immediately on a nonzero evaluator return code.

The evaluator, remote scorer, VLM/VLA interfaces, norm supplied through the
private inputs file, prompt mode, hold/release configuration, and autonomy
controls are inherited unchanged from frozen Task23 v155.

## Frozen Contract

- Parent package commit: `d622bef`.
- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- `MAX_STEPS=2000`, `REPLAN_STEPS=5`, one process per episode.
- All `ORACLE_*` controls are zero; VLM generates prompts; no object-moving
  anchor is permitted.
- Required stage-only success excludes optional `Close_Microwave`.
- Checkpoint and machine-local paths enter only through an untracked private
  environment file.

## Result Discipline

This is a fresh 20-episode run. It must not append v156's four valid episodes
or its aborted episodes. Raw outputs stay outside Git; Git receives a
sanitized aggregate, hashes, and the terminal result after the run finishes.
