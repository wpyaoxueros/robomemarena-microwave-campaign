# Task24 v132 Five-Node Attempt: Incomplete Result

- Slurm job: `429383`
- Frozen runtime revision at launch: `d904ae2978a6979ac76db8453f7bfabbe832477c`
- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`
- Requested seeds: `104` through `123`
- Prompt mode: VLM-generated prompts; all oracle prompt-injection flags were `0`.

## Result

| Category | Count |
| --- | ---: |
| Requested episodes | 20 |
| Valid official episodes | 16 |
| Invalid infrastructure episodes | 4 |
| Stage-only successes | 0 / 16 |
| Goal successes | 0 / 16 |
| Mean stage score over valid episodes | 35.3875% |

The valid-score distribution was one episode at `66.7%` and fifteen episodes at
`33.3%`. No valid episode completed all three required Task24 stages.

Seeds `104`--`107` are invalid rather than behavioral failures: their shared node
had pre-existing orphan GPU processes occupying both allocated GPUs. See
`invalid_worker0_gpu_oom_20260722_1640.md` for the root-cause evidence.

This does **not** constitute a formal 20-episode result. A replacement run must
reuse this frozen runtime and scorer, exclude `ACD1-1`, and rerun only seeds
`104`--`107` before any 20-episode metric is reported.
