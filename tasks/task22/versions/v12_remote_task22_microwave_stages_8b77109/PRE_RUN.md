# Task22 v12 Remote Microwave-Stage Replay

## Purpose

Evaluate Task22 with the remote scorer repair, not the legacy six-stage
runtime. The repaired remote scorer restores the Task22 sequence after the two
tomato-sauce pours:

1. lift tomato sauce;
2. pour once;
3. pour twice;
4. place tomato sauce aside;
5. open microwave;
6. place cookies in microwave;
7. close microwave (audit-only).

The first six stages are required. `07_Close_Microwave` remains in the trace
but is excluded from stage success and stage score.

## Pinned Remote Code

- Remote repository: `OpenHelix-Team/RoboMemArena`.
- Base remote commit: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Task22 repair commit: `8b7710924f862ab1c8dea69adada62e8c462de40`.
- Required branch: `codex/task22-microwave-stages`.

The launcher fails before rollout unless the supplied checkout is exactly the
repair commit and the Task22 stage contract passes.

Set `ROBOMEMARENA_REMOTE_ROOT_OVERRIDE` for the repaired checkout at launch.
This deliberately overrides any older default remote root in the ignored
private input file.

## Rollout Contract

- One episode, seed 104, 2000 maximum steps, replan interval 10.
- VLM-generated prompts only; every `ORACLE_*` control is zero.
- No object-moving anchor, object-region gate, lift gate, gripper gate, or
  completed-task prompt injection.
- The local integration wrapper only connects VLM/VLA to the remote stage
  scorer; it does not add Task22 stage rules.
- Runtime artifacts are ignored by Git. The launcher snapshots the scorer,
  task config, BDDL, manifest, logs, and checksums into the output directory.
