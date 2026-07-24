# Task7 Historical Two-GPU Reference Comparator

This launcher is the strict comparison path for the historical Task7 `4/8`
result. It invokes the frozen `run_task7_8ep.sh` directly rather than the
single-GPU compatibility overlay.

## Fixed Contract

- Frozen package: `counting/task7_vlm35999_latest_d9f83ac_hardcase500_20260724`
- Remote scorer: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- Episodes: seeds `100` through `107` (`NUM_TRIALS=8`, `SEED=100`)
- VLA: original fullvlm-v2 `35999`, self-contained matched norm
- VLM: recorded Task7 hard-case `checkpoint-500`; its file SHA256 is written
  to `reference_manifest.env` before rollout.
- Topology: VLA server uses visible GPU `0`; VLM/evaluator and MuJoCo use
  visible GPU `1` exactly as the frozen launcher specifies.
- LIBERO: the immutable d9 archived `evaluation_benchmark/libero_fork` root is
  injected as `TARGET_LIBERO_PATH`; the runtime checkout intentionally omits
  this external dependency.
- Rollout: `REPLAN_STEPS=5`, `POST_STAGE_STEPS=30`, `VLM_INTERVAL=25`, no
  stage prompt override, no oracle prompt injection.

## Run

From the submitting account after a fresh 1-GPU Slurm probe:

```bash
OUTPUT_ROOT=/data/user/<submit-user>/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725 \
bash evaluation_campaigns/all18_repo_direct_exact20_20260725/scripts/submit_task7_historical_topology_8ep.sh
```

The result is comparable to the historical `results.tsv` only if the output
contains `reference_manifest.env`, `run_manifest.txt`, `summary.tsv`, and all
eight per-episode logs/videos.
