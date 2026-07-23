# Task21 v126 Latest-Scorer Multi-Seed Replay

## Purpose

Replay the frozen Task21 v124 policy contract on three independent seeds. Seed
`107` is a same-seed confirmation of the prior valid success; seeds `108` and
`109` measure whether that outcome generalizes without changing runtime
behavior.

## Frozen Behavior

- Official scorer: RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- VLA and VLM selections are supplied only through a local ignored input file.
- `MAX_STEPS=2000`, `REPLAN_STEPS=5`, one episode per seed.
- All `ORACLE_*` controls remain `0`; the VLM is the only source of next
  primitive prompts.
- The tracked empty release-anchor object is retained: no robot-only or
  object-moving release anchor is added in v126.
- The v121 min-hold file remains caller-owned through the nested runner.
- `completed_struct` may provide past-state context but never writes a prompt.

## No Behavioral Delta From v124

This version changes only the seed list and the reproducibility wrapper. No
threshold, hold, prompt, scorer, anchor, VLA, or VLM setting changes.

## Scope

Run seeds `107`, `108`, and `109` in parallel only after a same-shell
one-GPU Slurm probe. Store result hashes and official stage outcomes in this
directory before using any result in an aggregate success rate.
