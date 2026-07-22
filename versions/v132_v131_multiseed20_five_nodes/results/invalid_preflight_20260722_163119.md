# Invalid Preflight: 2026-07-22 16:31 CST

## Status

Invalid before rollout. This is not a Task24 measurement and must not be used
in any success-rate table.

## What happened

The five-node allocation was obtained and all 20 worker slots were created,
but every slot exited before policy-server or environment startup because the
non-login Slurm worker did not inherit `VLA_CONFIG` from the historical login
shell. No episode summary, official stage record, manifest, video, or rollout
step was produced.

## Root cause and correction

The historical v131 input template fixes the configuration name to
`pi05_libero_robomemarena_fullvlm_v2_noflip_dataset`; historical interactive
launches inherited it through their shell. v132 now exports that same public
configuration name in `run_one.sh` after loading private inputs, so every
worker receives the identical setting without depending on shell inheritance.

## Validation impact

All 20 records failed `validate_episode.py` because the required evaluator
artifacts were absent. The valid-episode count is `0/20` and the result is
explicitly excluded from aggregation.
