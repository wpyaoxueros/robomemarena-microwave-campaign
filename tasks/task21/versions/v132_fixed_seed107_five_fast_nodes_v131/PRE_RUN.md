# Task21 V132: Fixed-Seed107 on Five Verified-Fast Nodes

## Purpose

Repeat the fixed-seed107 20-rollout Task21 measurement on five physical nodes
while excluding the two nodes measured to have a node-level rollout latency
regression in V131.

## Frozen Behavior

V132 delegates to the committed V131 multi-node worker and therefore to V130
and V127 for the actual rollout. The only change is Slurm placement:

- Five nodes, one worker per node, two GPUs per node.
- Exclude `ACD1-39,ACD1-40`, where identical V131 rollouts took about 20
  seconds per five actions instead of the historical roughly 0.8 seconds.
- Every worker still runs four independent `NUM_TRIALS=1`, `SEED=107`
  rollouts for exactly 20 attempts total.

The scorer commit, VLM autonomy contract, optional close stage, EEF
hold/release, and robot-only anchor behavior are unchanged from V131/V130.
Model checkpoint locations stay in an ignored private input file.
