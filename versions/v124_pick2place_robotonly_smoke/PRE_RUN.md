# Task24 v124 Pre-run Contract

## Purpose

Test one boundary-only change against v123: after the VLM itself emits
`place cookies` while the `pick cookies` EEF hold is active, reset only robot
and gripper state to the matching training subtask frame. No object body is
moved.

## Fixed from v123

- VLA and VLM checkpoint selections come from the ignored private input file.
- Official scorer: RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Required scorer: `task2_26_reference_stage.py`; missing file is fatal.
- VLM remains the sole prompt source.
- Every `ORACLE_*` flag remains `0`.
- No completed-subtask prompt context, object gate, object lift gate, or
  object-moving anchor is enabled.
- EEF target files, tolerances, passage rule, direction rule, and 50-step
  post-pick dwell are byte-identical to v123.

## Only delta

`config/release_anchors_t24_add_pick2place_robotonly_20260722.json` adds the
single `pick cookies -> place cookies` robot-only anchor at frame 40. The
existing `open microwave -> pick cookies` and `place cookies -> pick popcorn`
robot-only anchors remain unchanged.

## Smoke scope

Run one episode each for seeds `107` and `108`. Record raw artifact hashes,
official stage result, and all prompt/anchor events before deciding whether to
expand the variant.
