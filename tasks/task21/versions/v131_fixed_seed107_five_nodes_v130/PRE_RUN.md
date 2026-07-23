# Task21 V131: Fixed-Seed107, Five-Node Repeatability Evaluation

## Purpose

Run the fixed `seed=107` Task21 repeatability measurement as exactly five
physical Slurm nodes, with one worker per node and four independent rollouts
per worker.

## Frozen Behavior

V131 delegates each rollout to the committed V130 worker, which in turn uses
the successful V127 rollout entry point. It changes only Slurm topology:

- `--nodes=5 --ntasks=5 --ntasks-per-node=1`
- two GPUs per node
- worker IDs are the Slurm task IDs `0..4`
- every worker independently runs four `NUM_TRIALS=1`, `SEED=107` rollouts

Therefore V131 is still a fixed-seed reliability measurement, not a multi-seed
generalization result. The remote scorer remains
`62214036103ee8d5fef9b475dd8b344b6e2cfc03`; VLM prompt selection remains
autonomous and all oracle prompt flags remain zero through the V130 validator.

Each task writes `ALLOCATION.txt` before executing its first rollout, recording
the Slurm job/task IDs and hostname. The final aggregate is valid only when all
20 attempts pass V130 validation.

Checkpoint paths remain in an ignored private input file and are not recorded
in this repository.
