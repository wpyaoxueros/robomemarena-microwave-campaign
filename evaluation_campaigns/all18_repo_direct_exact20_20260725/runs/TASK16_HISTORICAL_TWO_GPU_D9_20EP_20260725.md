# Task16 Historical Package, d9 20-Episode Replay

## Result

- Episodes: `20/20`, seeds `100..119`.
- Current d9 stage success: `17/20 = 85.0%`.
- Mean stage score: `90.0%`.
- Goal audit rate: `18/20 = 90.0%`.
- The values are from the completed `summary.tsv`, not inferred from videos.

## Reproducible Runtime

- Submit account and job: `xiangqim`, `437552`.
- Output root:
  `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/counting_historical_two_gpu/task16_historical_d9f83ac_exact20_20260725_114200_d9frozen`.
- Two visible GPUs: VLA server `0`; VLM/evaluator and MuJoCo EGL `1`.
- VLA checkpoint:
  `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`.
- Checkpoint-owned norm:
  `assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`
  (`4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`).
- VLM checkpoint:
  `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/counting_vlm35999_latest_d9f83ac_2ep_20260723/runs_stageprompt/training_task16_pick_postlift_balanced_vlm_20260724_201612_emergency_acd/checkpoint-100`.

## Scoring And Controls

- RoboMemArena commit:
  `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Stage scorer SHA256:
  `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.
- `oracle_prompt_injection=off`; VLM chooses prompts.
- The frozen package retains only its recorded Task16 rotation-return controller assist.
- Full command/config hashes and per-episode traces are in
  `historical_runtime_manifest.env`, `run_manifest.txt`, and `task16/ep*/sync_vlm.log`
  below the output root.
