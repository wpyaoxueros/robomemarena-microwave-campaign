# Task22 v2 Invalid Startup Record

## Status

Job `428606` was cancelled before the evaluator began and produced no episode
summary or rollout result.

## Reason

The job was created during submission-script diagnostics, but that diagnostic
shell was not the same remote shell that ran the required fresh 1-GPU Slurm
probe.  It therefore did not meet the frozen submission contract and was
cancelled rather than used as an evaluation.

## Scope

- No Task22 success or failure is attributed to this job.
- No video, scorer result, or model behavior is reported from it.
- The next launch must run the probe and tmux submission within one remote
  shell script.
