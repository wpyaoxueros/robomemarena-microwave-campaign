# v12 Invalid Pre-Rollout Attempt

- Slurm job: `431802`.
- The job exited before the policy server, VLM, environment, or episode loop
  started.
- No video, stage result, CSR, or TSR was produced by this attempt.

## Failure

`inputs.env` supplied an older default `ROBOMEMARENA_REMOTE_ROOT` after the
launcher had received the repaired checkout path. The v12 commit guard caught
the mismatch (`expected 8b77109`, received legacy `6221403`) and stopped the
job before rollout.

## Correction

The v12 launch path now requires
`ROBOMEMARENA_REMOTE_ROOT_OVERRIDE` and reapplies it after loading private
inputs. The next run will re-run both GPU probes and the remote stage-contract
check before the policy server starts.
