# Task18 original snapshot replay

This version replays the historical Task18 evaluator without modifying its
rollout code. It is deliberately separate from the current remote-scoring
adapter line.

## Frozen source identity

The source of truth is the local historical `repro_snapshot` created on
2026-07-04. The launcher requires its location through `SNAPSHOT_DIR`; model
paths are deliberately supplied only through local environment variables.

Expected SHA256 values:

| Artifact | SHA256 |
| --- | --- |
| historical evaluator | `7367e68f05712d4620429ecdbebbcbe6289da6613863db6dfcee926e8216b4c1` |
| historical launcher | `11aba57fac364c8e9fc9f430c44edf7677defcdd00982667b75e07f98cc9cebd` |
| historical base evaluator | `265162087a6d77fa44808c34bd8525c183ec0c3a376430a67314864e8a0b56ea` |
| hold target JSON | `8921ddbbda123ad419ac563397bb47ab95e3e696ee483c15d357f294beb5003d` |
| passage-count JSON | `4fb11fb0e440b42afd95674219ae007d75e29ae140f846d7221763987fbf54c6` |

## Fixed historical semantics

- Task: 18
- Trials: 5
- Seed: 104
- Max steps: 2200
- Replan steps: 5
- VLM mode: `english_reference_no_candidate`
- Completed-subtasks injection: off
- Rollout evaluator: historical snapshot evaluator only

`run_original_snapshot.sh` refuses to start if either historical Python or
launcher hash differs. It explicitly unsets modern campaign override variables,
including `ARCHIVED_TASKS_EVAL_OVERRIDE`; it does not import or call
`d9_compat.py`.

This is a historical-path replay, not a claim that its old scorer is the latest
remote RoboMemArena scorer. A current-scoring evaluation must be a separately
versioned experiment and must not replace the rollout evaluator here.
