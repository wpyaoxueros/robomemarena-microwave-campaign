# Invalid Path-Check Batch: 2026-07-22 16:33 CST

## Status

Invalid before rollout. This batch is excluded from all Task24 success-rate
reporting.

## What happened

All five workers received a five-node allocation, but every one of the 20
slots exited before policy-server or environment startup. The worker preflight
incorrectly applied a filesystem existence check to `VLA_CONFIG`, which is a
configuration identifier rather than a path.

## Root cause and correction

`run_one.sh` now validates path-valued private inputs with `-e`, while it only
requires `VLA_CONFIG` to be non-empty. The configuration value remains the
same frozen v131 setting; no model, prompt, scorer, or policy runtime setting
changed.

## Validation impact

The batch produced no `summary.tsv`, official episode record, manifest, video,
or rollout step. Its valid-episode count is `0/20`.
