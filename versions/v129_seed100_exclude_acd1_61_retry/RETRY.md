# Task21 v129: seed100 shard retry outside ACD1-61

This is a scheduling-only retry of Task21 v128's first shard (`seed=100`, four
episodes: 100--103). The initial v128 allocation on ACD1-61 advanced roughly
20 seconds per five-action chunk while the identical workers on the other
nodes advanced in roughly one second. It cannot finish four episodes within
the two-hour allocation.

Source behavior is frozen in the already-pushed v128 package at commit
`41bf43b`. This retry invokes that exact `run_shard.sh` and changes only the
Slurm placement with `--exclude=ACD1-61`.

Invariant settings inherited from v128:

- `NUM_TRIALS=4`, `SEED=100`, therefore episodes use seeds 100--103.
- VLM supplies prompts; all `ORACLE_*` prompt injection flags remain zero.
- Same EEF hold/release, completed context, robot-only anchor configuration,
  VLA/VLM private inputs, and RoboMemArena scorer.
- The output directory retains the runtime environment and copied retry
  scripts. Private checkpoint paths are never committed.
