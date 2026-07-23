# Task22 v18 Precheck Failure Record

- Time: 2026-07-23 19:03:58 Asia/Shanghai
- Submit user: `zzhang510`
- Slurm job: `432592`
- Requested shape: 2 GPUs, `acd_u`
- Result: failed before model server or environment rollout started.

## Failure

`verify_stageprompt_diagnostic.sh` invoked the account default `python3`.
That interpreter did not have `numpy`, while the configured inference virtual
environment did. The failure was therefore in the shell verifier interpreter
selection, not the checkpoint, dataset, scorer, simulator, or policy rollout.

## Corrective Change

The verifier now uses `ROBOMEMARENA_VERIFY_PYTHON` when supplied by the launch
script, with `python3` only as its standalone fallback. The next submission
must re-run the same account access check and fresh Slurm probes.

## Integrity

No episode, video, stage score, or success claim was produced by job `432592`.
