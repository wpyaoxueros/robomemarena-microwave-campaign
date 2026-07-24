# Task21 D9 Single-GPU Direct20

This is the current direct-use reproduction entrypoint for the frozen Task21
package. It preserves the Task21 v130 fixed-seed-107 protocol: five sequential
workers, four independent one-episode resets per worker, for 20 total valid
official episode summaries.

## Source and Scorer

- Frozen source package: `tasks/task21`.
- Job-local overlay builder:
  `scripts/materialize_microwave_d9_overlay.py`.
- Official source:
  `/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725`.
- Required official commit:
  `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Required scorer:
  `evaluation_benchmark/scripts/task2_26_reference_stage.py`.
- Required scorer SHA256:
  `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.

The overlay copies the original package and replaces only the pinned scorer
commit references. The original package is not edited. Its manifest records
the original tree hash, every replaced reference, the d9 scorer hash, and the
overlay path.

## Local Model Assets

- VLA: `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`.
- Norm: `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`.
- VLM: `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260701_082527_task21r17c_task21_r17_openkeep_latepick_rawtrace_open_microwave_to_pick_butter/hzhang061/eval_artifacts/vlm_eval_ready/task21_task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000_20260701_100519/task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000`.
- Task data: `/data/user/hlei573/data/full_trajectory_v2/21_butter_chocolate_microwave_dataset`.

## Runtime Contract

- Entry point:
  `scripts/run_task21_d9_direct20_single_gpu.sh`.
- One Slurm-visible GPU only. VLA and VLM are both bound to logical device
  `0`; no second GPU is allocated.
- The original Task21 package keeps VLM prompt selection, the empty release
  anchor template, its completed-structure context, EEF hold/release, and its
  original `MAX_STEPS` and `REPLAN_STEPS` settings.
- All `ORACLE_*` prompt controls remain zero in the original v121 runtime.
- A result counts only when the overlay validator accepts all 20 independent
  summaries and the aggregate script emits a valid 20-row result.

## Launch

Run inside a one-GPU Slurm allocation with `OUTPUT_ROOT` set to the submitting
account's writable output root:

```bash
OUTPUT_ROOT=/data/user/<submit-user>/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725 \
  bash evaluation_campaigns/all18_repo_direct_exact20_20260725/scripts/run_task21_d9_direct20_single_gpu.sh
```

## Excluded Infrastructure Attempt

- `20260725_070600` on `xiangqim`, Slurm job `437089`, is excluded before
  rollout: the generated private input file did not export its path variables,
  so every child evaluator exited at `OPENPI_ROOT` validation before producing
  a summary, video, or stage result. The fixed launcher exports the same
  recorded variables and is covered by the static contract test.
