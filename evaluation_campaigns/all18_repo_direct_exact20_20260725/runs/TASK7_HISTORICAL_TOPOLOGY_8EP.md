# Task7 Historical Two-GPU Reference Comparator

This launcher is the strict comparison path for the historical Task7 `4/8`
result. It materializes a byte-identical execution copy of the frozen package,
adds only the missing read-only official-source link required by the frozen
evaluator, then invokes its unchanged `run_task7_8ep.sh`. It does not use the
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
- Execution package: the submitter output root contains a generated copy of the
  frozen runner/scripts/evaluators. Their SHA256 values are checked equal to the
  frozen files and recorded in `execution_pack_manifest.json`. The only added
  entry is `source/RoboMemArena_d9f83ac`, a read-only link to the fixed d9
  source checkout. This is required because the frozen evaluator resolves that
  path relative to its own package directory.
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

## Invalid Launch Record

- Job `437124` (2026-07-25) allocated two GPUs and loaded the VLA server, but
  exited before episode 0 because the frozen evaluator resolved its official
  source as `PACK_DIR/source/RoboMemArena_d9f83ac/...` and that link had not
  been materialized. It produced no episode summary and is invalid.
- The execution-pack materialization above is the narrow fix. A submit-account
  preflight created the package and verified the original runner/evaluator
  hashes before the replacement launch.
