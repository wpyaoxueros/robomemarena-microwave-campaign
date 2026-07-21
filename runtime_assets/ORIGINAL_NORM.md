# Original VLA Norm Asset

- Asset ID: `robomemarena_fullvlm_v2_noflip_dataset_v2`
- SHA256: `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`
- File: `runtime_assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`

该文件的数值来自 original fullvlmv2 VLA 35999 使用的训练 repo norm。它同时安装到该
VLA checkpoint 的 `assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`。运行
入口会在 rollout 前用 `cmp` 校验两者逐字节一致，避免任何 checkpoint 或数据配置 fallback。
