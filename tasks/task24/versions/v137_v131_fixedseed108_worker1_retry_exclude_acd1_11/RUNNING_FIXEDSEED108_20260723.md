# Task24 Fixed-Seed 108 Running Record

- Goal: 20 independent one-episode rollouts with `seed=108`.
- Scorer: RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03` with
  `task2_26_reference_stage.py`.
- Prompt policy: autonomous VLM; all oracle prompt-injection flags are zero.
- Runtime: frozen v131 rollout runtime and its historical no-asset norm fallback
  route.

## Scheduling Record

- v136 launched five independent two-GPU workers rather than a five-node gang
  allocation, so workers can start independently on any eligible node.
- The original worker1 allocation on `ACD1-11` was cancelled before producing a
  valid row because it sustained roughly 20 seconds per five-step VLA chunk.
- v137 replaces only that worker's four attempts and excludes `ACD1-11`; model,
  seed, scorer, VLM policy, and rollout logic are unchanged.

## Checkpoint Status

At the time of this record, 19 valid attempts had completed: 15 stage successes
and 4 failures. The twentieth attempt remained in progress. A separate final
result record will be committed after aggregation.
