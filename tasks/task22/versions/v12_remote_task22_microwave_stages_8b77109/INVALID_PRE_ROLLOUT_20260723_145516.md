# v12 Invalid Pre-Rollout Attempt 2

- Slurm job: `431808`.
- The job exited before policy-server startup, VLM loading, environment reset,
  or episode execution.
- No score, video, or stage result is associated with this attempt.

## Failure

The shared tmux server did not inherit the repaired-checkout override from the
submitter shell. The inner `srun` therefore stopped at the required
`ROBOMEMARENA_REMOTE_ROOT_OVERRIDE` guard.

## Correction

The launcher now injects the override directly into the inner `srun` command.
This removes tmux environment inheritance from the scorer-selection contract.
