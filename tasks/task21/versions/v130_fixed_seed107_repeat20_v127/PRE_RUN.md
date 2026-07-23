# Task21 V130: Fixed-Seed107 Repeatability Evaluation

## Purpose

Measure whether the previously successful Task21 `seed=107` condition is
repeatable across 20 fully independent environment and policy-process resets.
This is a fixed-seed reliability measurement, not a multi-seed generalization
score.

## Frozen Evaluation Contract

- Source rollout behavior: `v127_single_seed107_serial_replay/run_one.sh`.
- Every attempt uses `NUM_TRIALS=1` and `SEED=107`.
- Five workers run four independent attempts each, for exactly 20 attempts.
- Each attempt starts a fresh evaluator and policy-server lifecycle. A worker
  never advances `ep`, so the evaluator cannot turn the fixed seed into
  `seed + ep`.
- Remote scorer commit: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Required final stages: Open Microwave, Place Butter, Place Chocolate.
  Close Microwave remains optional.
- All oracle prompt flags must remain zero. The VLM selects prompts; EEF
  hold/release and robot-only release anchors may regulate timing only.

## Evidence and Validation

Every attempt must write its own `summary.tsv`, `official_episodes.tsv`,
`run_manifest.json`, immutable evaluator snapshot, and `validation.json`.
`aggregate_fixedseed20.py` rejects the result unless all five workers completed
four valid attempts and all 20 rows prove `seed=107`.

Model checkpoint locations are provided only through an ignored local private
input file and are deliberately absent from this repository.
