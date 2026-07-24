# Task18 v2 local runtime manifest

This manifest records the exact local assets used for the historical-path
replay. These paths are intentionally versioned for reproducibility.

| Role | Exact local path |
| --- | --- |
| VLA policy checkpoint | `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999` |
| VLM checkpoint | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_110452_task18_clean_completed_clean_task18_r9_clean_lateboundaries/hlei573/eval_artifacts/vlm_eval_ready/task18_20260702_130310_20ep_split_chunk0_seed104/task18_english_ref_20260702_110805_ckpt1000` |
| VLA checkpoint norm asset | `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999/assets/robomemarena_fullvlm_v2_noflip_dataset_v2` |
| Historical Task18 snapshot | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task1_2_3_12_13_18_25_26_remote_sync_eval_exact_20260704/source_snapshots/task18/repro_snapshot/task18_r9_exactalign_lift0_chunk0_seed104_20260704_230905_20260704_230905_pid290105` |
| Historical base evaluator | `/data/user/hlei573/tmp/rma_refeval_fresh_20260513_052445/RoboMemArena/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py` |
| OpenPI runtime root | `/data/user/hlei573/openpi` |
| Inference runtime root | `/data/user/hlei573/openpi_inference` |
| LIBERO source root | `/data/user/hlei573/RoboMemArena_github/LIBERO/libero` |

## Fixed replay parameters

```text
task=18
num_trials=5
seed=104
max_steps=2200
replan_steps=5
vlm_task_text_mode=english_reference_no_candidate
vlm_completed_subtasks_mode=off
vla_action_target_mode=raw
```

The runtime logs must report the checkpoint norm asset above; a fallback to a
different norm asset invalidates this version's reproduction claim.
