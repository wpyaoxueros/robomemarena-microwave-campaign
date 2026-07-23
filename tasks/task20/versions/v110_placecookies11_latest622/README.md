# Task20 v110 place-cookies 0.11

该版本固定到 RoboMemArena commit
`62214036103ee8d5fef9b475dd8b344b6e2cfc03`，并使用：

- VLA 标识：`fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338`，step `35999`。
- VLM 标识：`task20_mwvlm_no_completed_v49_ckpt24`。
- Norm SHA256：`4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`。
- `MAX_STEPS=1000`，`REPLAN_STEPS=10`。
- 所有 `ORACLE_*` 为 `0`，VLM 自主输出 prompt。
- EEF-only hold；不使用 object/lift/gripper/region gate。
- 相对 v49c6 的关键行为差异：`place cookies` 的 EEF hold 阈值从
  `0.06 m` 放宽到 `0.11 m`。

运行入口：

```bash
cp versions/v110_placecookies11_latest622/paths.example.env .env
# 编辑 .env，填入本机路径。
set -a
source .env
set +a
CUDA_VISIBLE_DEVICES=0,1 SEED=106 bash scripts/run_task20_v110.sh
```

模型权重不在仓库中，所有路径都通过 `.env` 传入。20ep 正式结果仍在运行，
完成后会以独立 commit 追加 `summary_20ep.json` 和逐 episode 记录。
