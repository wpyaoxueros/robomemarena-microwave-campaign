# Archived Repro20 Historical Topology

## Scope

This entrypoint directly reproduces the historical 8-task package for Tasks
1, 2, 3, 12, 13, 18, 25 and 26. It is separate from the d9 single-GPU campaign
workers and must never be merged with their results.

## Frozen Runtime

- Source: `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/repro20_remote_metrics_20260704_175011`
- Historical scorer commit: `66e7894f8188be8114911e5df0f8bf89fe4581ce`
- Original allocation: two GPUs per task, VLA on the first visible GPU and
  VLM/evaluator on the second visible GPU.
- VLA: `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`
- Norm: `assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`
- Task-specific VLM paths are frozen in
  `scripts/run_archived_repro20_historical_topology.sh` and written to every
  `historical_runtime_manifest.env`.

## Invocation

From the actual submitting account after a fresh two-GPU probe:

```bash
OUTPUT_ROOT=/data/user/<submit-user>/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725 \
  bash scripts/submit_archived_repro20_historical_topology.sh 18
```

The runner verifies the historical source hashes before it starts. It uses the
archived `run_one.sh` directly, preserves its task-specific parameters, and
does not inject the current d9 evaluator or a single-GPU overlay.
