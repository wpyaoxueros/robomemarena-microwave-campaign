# Archived Direct-Use Single-GPU Batch

## Intent

This is the first fresh batch for the All-18 direct-use campaign. It verifies
that the committed archived task packages can run with their recorded VLA and
VLM checkpoints while VLA and VLM share one allocated GPU.

The only launcher change is GPU-device binding: both processes receive device
`0` inside a one-GPU Slurm cgroup. Rollout parameters, VLM checkpoint, VLA
checkpoint, norm, scorer, and task-specific frozen package settings are not
changed.

## Frozen Inputs

- Launcher commit: `3734441`
- Scorer: `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- Scorer file SHA256: `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`
- VLA: `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`
- Norm: `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`
- Norm SHA256: `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`

## Running Instances

| Task | Slurm job | Node | GPU binding | Output root | Port | Status at launch |
| --- | --- | --- | --- | --- | ---: | --- |
| 1 | 436954 | ACD1-3 | VLA=0, VLM=0 | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task1/task1_all18_direct20_seed104_20260725_055518` | 9811 | server loading |
| 3 | 436952 | ACD1-11 | VLA=0, VLM=0 | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task3/` | 9813 | server loading |
| 25 | 436955 | ACD1-3 | VLA=0, VLM=0 | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task25/` | 9835 | evaluator started |
| 26 | 436953 | ACD1-11 | VLA=0, VLM=0 | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task26/` | 9836 | server loading |

Raw logs are under:

`/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/launcher_logs/`

Each worker creates its own `launch_records/<run_id>.env` before rollout.
