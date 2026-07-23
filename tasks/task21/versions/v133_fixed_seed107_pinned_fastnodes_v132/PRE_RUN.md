# Task21 V133: Fixed-Seed107 on Pinned Verified-Fast Nodes

## Purpose

Run the fixed `seed=107` Task21 20-rollout repeatability measurement on five
physical nodes whose matching rollout conditions have already demonstrated
historical action-chunk speed.

## Pinned Allocation

V133 requests exactly these nodes, one worker per node and two GPUs per node:

```text
ACD1-3, ACD1-4, ACD1-6, ACD1-9, ACD1-38
```

The node list is evidence-based: each node was directly observed running the
same V131/V132 seed107 configuration at the expected sub-second five-action
chunk cadence. Nodes `ACD1-1`, `ACD1-39`, and `ACD1-40` are excluded because
they sustained roughly 20 seconds per five-action chunk.

## Frozen Rollout Contract

V133 delegates to V131's five-node worker, then V130 and V127. Thus every
attempt remains an independent `NUM_TRIALS=1`, `SEED=107` rollout; VLM chooses
the task prompts, all oracle prompt flags remain zero, and the current remote
scorer and optional-close stage policy remain unchanged. The five workers each
run four attempts, producing exactly 20 attempts.

Checkpoint locations remain in an ignored private input file and are not
committed to this repository.
