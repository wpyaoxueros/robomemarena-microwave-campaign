# Task1 and Task3 Direct Formal Submission

## Intent

Run Task1 and Task3 independently for exactly 20 episodes each. Task2 is not
part of this batch.

## Frozen contract

- VLA: original fullvlm-v2 noflip `35999` with the original matching norm.
- VLM: each task's archived successful-run VLM checkpoint, supplied only from
  the private runtime environment and intentionally not written to Git.
- Rollout: the archived task-specific wrapper and hold/passage settings are
  used unchanged.
- Official scoring source: `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Required scorer: `task2_26_reference_stage.py`, SHA256
  `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.
- The runner fails rather than falling back to `eval_tasks2_26.py`.

## Resource contract

- Submit account: `zzhang510`, with no explicit `-A`.
- Partition: `emergency_acd` after fresh `acd_u -> acd_ue -> emergency_acd`
  escalation.
- Per task: 2 GPUs, 16 CPUs, 480 GB, 12-hour limit.
- Each task runs in its own tmux session and receives a separate port.

## Result recording

The external output directory will retain the run manifest, frozen active
code, scorer, BDDL, per-episode logs and videos. The final result is appended
to this repository only after the generated summaries pass the same scorer
preflight.
