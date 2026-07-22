# Task22 v6 Legacy Seed104 Replay

## Purpose

Replay the historical Task22 seed104 rollout whose old evaluator log recorded all
six legacy stages as complete. This is a legacy-evaluator reproduction, not a
result under the current remote stage scorer.

## Recovery Basis

- Historical launcher timestamp: 2026-07-07 13:46:54 +0800.
- Historical rollout settings: Task22, seed104, one fresh process per episode,
  2000 maximum steps, VLA replan interval 10, asynchronous VLM interval 5.
- The historical `summary.tsv` and `prompt_trace.tsv` schema exactly match the
  evaluator at RoboMemArena commit `b175708317abacfbce86c4911cc492d68a3ea163`.
- The frozen runtime includes that evaluator, its minimal runtime dependencies,
  the Task22 BDDL, the original policy server, and a hash manifest.
- The historical log contains VLM raw primitive outputs and no oracle prompt
  injection record. The replay uses the same VLM-driven prompt path.

## Contract

- `NUM_TRIALS=1`, `SEED=104`, `MAX_STEPS=2000`, `REPLAN_STEPS=10`.
- The output is valid only when `verify_snapshot.sh` passes, the local input
  paths are readable, and a full episode summary and MP4 are produced.
- A matching stage-complete rollout is a successful legacy reproduction. A
  different trajectory or failure is still a valid result and must be recorded.
- This version must not be reported as a current `6221403` scorer result.

## Execution

1. Create an untracked `inputs.env` from `inputs.example.env`.
2. Run `bash verify_snapshot.sh`.
3. From a validated `zzhang510` shell, run `bash probe_2gpu.sh`.
4. Launch `bash submit_zzhang510.sh /absolute/path/to/inputs.env`.

