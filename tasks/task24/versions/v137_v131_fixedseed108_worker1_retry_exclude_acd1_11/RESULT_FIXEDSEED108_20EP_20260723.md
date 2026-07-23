# Task24 v131 Fixed-Seed 20-Attempt Result

## Result

All 20 independent attempts used environment `seed=108` and passed the
per-episode validation checks.

| Metric | Value |
| --- | ---: |
| Valid attempts | 20 / 20 |
| Stage successes | 14 / 20 (70.0%) |
| Goal successes | 14 / 20 (70.0%) |
| Mean stage score | 85.0% |
| 100.0% stage score | 14 |
| 66.7% stage score | 3 |
| 33.3% stage score | 3 |

The scorer is RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03`
with `task2_26_reference_stage.py`. All attempts used autonomous VLM prompts;
oracle prompt-injection flags were zero.

## Provenance

- Sixteen rows came from v136 workers 0, 2, 3, and 4, frozen at
  `e5c70e2c0c40a33b01cd493168b652b681b020fe`.
- Four rows came from the v137 worker1 replacement, frozen at
  `3b20c83eea57d67b8289faac18b61aed03f3b629`.
- The first v136 worker1 allocation produced no valid row because its
  `ACD1-11` allocation sustained roughly 20 seconds per five-step VLA chunk.
  Its replacement excluded that node. This changed scheduling only; the
  model, seed, scorer, VLM policy, norm fallback, and rollout runtime were
  unchanged.

The local merged 20-row attempt table has SHA-256
`9d7ad3799dd63160bf889129c8317bad6e03e9e29f621afc13e1ba41858cb4b6`.
