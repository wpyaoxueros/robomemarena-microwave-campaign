# Task18 d9f83ac single-GPU run stopped by user

- Slurm job: `436817` submitted as `xiangqim`.
- Worker: Task18 on one allocated GPU, with VLA and VLM colocated.
- Remote scorer: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- VLA: `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`.
- VLM: `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_110452_task18_clean_completed_clean_task18_r9_clean_lateboundaries/hlei573/eval_artifacts/vlm_eval_ready/task18_20260702_130310_20ep_split_chunk0_seed104/task18_english_ref_20260702_110805_ckpt1000`.
- Private output: `/data/user/xiangqim/hlei573_borrow_outputs/latest_openhelix_d9f83ac_exact20_20260725/task18/task18_openhelix_d9f83ac_exact20_seed104_20260725_030249`.

## Partial result

The worker completed episodes `0` through `8`, all with remote stage success `0`:

- Completed: `9/20`
- Stage success: `0/9`

## Stop disposition

The user requested that this worker be stopped because the d9f83ac single-GPU replay was suspected to be the wrong runtime/evaluator path for the intended Task18 comparison. Only the Task18 process branch was terminated; Task12 and Task13 workers in the same allocation continued.

This is an incomplete diagnostic run and must not be reported as a Task18 formal 20-episode result.
