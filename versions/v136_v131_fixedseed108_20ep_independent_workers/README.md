# Task24 v131 Fixed-Seed Independent Worker Reproduction

This version repeats `seed=108` twenty times through five independent Slurm
workers. Each worker requests one node with two GPUs and runs four sequential
one-episode attempts.

Unlike the v135 gang allocation, the five workers do not wait for five nodes to
become available at the same instant. Slurm can start each worker on any
eligible node as resources become available. This changes scheduling only; the
frozen v131 runtime, scorer, seed, autonomous VLM prompt policy, norm fallback,
and per-attempt validation are unchanged.

Use `dispatch_fixedseed20_independent_zzhang510.sh` from the validated account.
The batch root contains one live-status file and one `attempts.tsv` per worker.
Run `aggregate_fixedseed20.py <batch-root>` after all five workers finish.
