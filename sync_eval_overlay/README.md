# RoboMemArena Sync-Eval Microwave Overlay

This directory replaces `evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference` while keeping the upstream sync-eval invocation interface.

Required inputs are unchanged: `OPENPI_ROOT`, `OPENPI_INFERENCE_ROOT`, `TARGET_LIBERO_PATH`, `VLM_CKPT`, and `VLA_CKPT`. Optional upstream controls such as `TASKS_JSON`, `NUM_TRIALS`, `SEED`, `REPLAN_STEPS`, `MAX_STEPS`, `POST_GOAL_STEPS`, `OUT_ROOT`, and GPU bindings remain supported.

Install into a RoboMemArena checkout:

```bash
bash sync_eval_overlay/install_into_sync_eval.sh \
  /path/to/RoboMemArena/evaluation_benchmark/reference_evaluation
```

Before a model rollout, set `ROBOMEMARENA_OFFICIAL_ROOT` to that checkout. The runner verifies the official BDDL and `task2_26_reference_stage.py` exist, writes `runtime_contract.env`, and saves the normal sync-eval summaries, videos, logs, and prompt trace under `OUT_ROOT`.
