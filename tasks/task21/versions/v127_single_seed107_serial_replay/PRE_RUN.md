# Task21 v127 Single-Instance Seed107 Replay

## Purpose

This run tests whether v126's three `SIGABRT` terminations were caused by
parallel runtime pressure. It replays the frozen autonomous Task21 contract on
only seed 107, which was a valid v124 success.

## Fixed Contract

- Official scorer commit: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- One two-GPU rollout process, no other Task21 rollout launched by this
  dispatcher.
- `MAX_STEPS=2000`, `REPLAN_STEPS=5`, seed 107, and port 9801.
- All oracle prompt controls remain zero; the VLM supplies prompts.
- The tracked release-anchor object is empty. No object-moving or robot reset
  anchor is enabled.
- No scorer, model, VLM, VLA, hold threshold, prompt, or data change is made.

## Validity Rule

Only a completed episode with an official summary and video is a valid result.
An abort, missing summary, or missing video is recorded as infrastructure
failure and excluded from the success rate.
