# Task24 v133 Clean-GPU Retry

This is a scheduler-only retry for invalid Task24 v132 seeds `104`--`107`.

- It calls v132's frozen `run_one.sh`; it does not alter VLA, VLM, hold/release,
  prompt, anchor, or scorer behavior.
- It requires the same pinned official scorer and refuses to run without
  `task2_26_reference_stage.py`.
- It uses four nodes with two GPUs each and excludes `ACD1-1`.
- Each worker records its GPU memory before loading either model. A node above the
  configured `4096 MiB` threshold is invalidated before rollout rather than being
  misreported as a task failure.
- The dispatcher runs a no-account 1-GPU Slurm probe in the same `zzhang510` shell
  before requesting the retry allocation.

Private paths are supplied only through `PRIVATE_INPUTS_FILE`; they are not stored
in this repository.
