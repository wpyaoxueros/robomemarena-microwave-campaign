# Task24 v131 Fixed-Seed 20-Attempt Reproduction

This version runs twenty independent Task24 rollouts with the same environment
seed, `108`. A five-node Slurm allocation starts one worker per node; each
worker runs four sequential one-episode attempts.

It freezes the successful v131 runtime and uses the same scorer commit,
autonomous VLM prompt policy, isolated no-asset VLA checkpoint view, and norm
fallback route as `v134`. The only new behavior is scheduling and recording
twenty independent repetitions. No worker changes the seed, inserts oracle
prompts, or shares an environment state with another attempt.

Run with `dispatch_fixedseed20_zzhang510.sh` from the validated borrowed
account after a five-node resource-shape probe. Use
`aggregate_fixedseed20.py <batch-root>` only after workers finish to produce a
machine-readable aggregate.
