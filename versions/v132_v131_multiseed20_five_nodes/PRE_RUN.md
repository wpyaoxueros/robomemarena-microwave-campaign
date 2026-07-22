# Task24 v132: v131 Multiseed 20-Episode Replay

## Scope

This version replays the successful Task24 v131 runtime on the standard 20
independent seeds `104..123`. Five Slurm tasks run four one-episode rollouts
each on five physical nodes.

## Frozen behavior

- Parent runtime: `v131_lr5e7c6_latest622_autonomous_20260718`.
- Official scorer commit: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- VLM mode: `vlm_free`; the VLM supplies task prompts.
- All `ORACLE_*` flags are zero.
- Hold/release uses EEF geometry, completed-stage context, and robot-only
  release anchors. No object-moving anchor, object-region gate, lift gate, or
  gripper gate is enabled.
- `pick popcorn` uses the v131 tolerance `0.07 m`; all other v131 tolerance,
  passage, direction, and release settings are snapshotted under `runtime/`.
- Required Task24 stages are open microwave, place cookies, and place popcorn.
  Closing the microwave is optional for the stage-only result.

## Reproduction contract

`run_one.sh` requires a local, ignored private input file through
`PRIVATE_INPUTS_FILE`. The file supplies model, dataset, and output paths and
is never committed. The runner checks the scorer commit and refuses to run if
`task2_26_reference_stage.py` is unavailable.

`run_worker.sh` assigns seed `104 + global_episode`, so worker 0 covers
104--107 and worker 4 covers 120--123. Every attempt validates its own
manifest, scorer snapshot, seed, and all oracle flags before aggregation.

## Intentional changes from v131

Only the dispatcher and result bookkeeping are new. The VLA checkpoint, VLM
checkpoint, prompt behavior, scorer, runtime policy scripts, and v131 hold
configuration are unchanged.
