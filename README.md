# RoboMemArena Task20 v49c6 Reproduction

这是 Task20 v49c6 的冻结评测包。VLM 自主输出子任务 prompt；运行时只使用 EEF hold/release、第二次经过计数和机器人状态 anchor 控制切换时机。它不注入下一个 prompt，不使用 object anchor，也不使用物体/夹爪/lift/region gate。

该包复现的是历史 v49c6 口径，官方 RoboMemArena 必须固定在 commit `514ecdf86ba47d496ab1728a827670833107ffd3`。这不是后续 `6221403` 最新 stage-scorer 的结果，不能混报。

## 已记录结果

冻结首次成功：seed104，stage=100%，goal=100%。2026-07-21 的独立复跑中，两个已完成 episode 也得到 stage=100%、goal=100%。视频、checkpoint、训练数据和原机器路径均不在本仓库。

## 使用的 checkpoint

权重不在仓库中。通过本机 `.env` 提供路径：

- VLA：`fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338`，step `35999`。
- VLM：`task20_v49c6_strict_autonomous_20260714`。
- Norm：仓库内 `assets/norm_repo/norm_stats.json`，SHA256 为 `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`。

## 准备

1. 准备 OpenPI、OpenPI inference 和 LIBERO 环境。
2. 使用 `scripts/bootstrap_robomemarena.sh <checkout-dir>` 获取固定的官方 checkout。
3. 复制 `paths.example.env` 为私有 `.env`，填入模型、环境和 Task20 subtask HDF 根目录。

## 运行

```bash
set -a
source .env
set +a

CUDA_VISIBLE_DEVICES=0,1 SEED=104 bash scripts/run_task20_v49c6.sh
```

每次只运行一个 episode。结果会写入 `outputs/` 或 `OUTPUT_ROOT`，其中包含 `run_manifest.json`、`code_snapshot/`、官方 scorer 快照、配置和 SHA256。

## 自主性约束

启动脚本会固定所有 `ORACLE_*` 为 `0`，并禁止 object/lift/gripper/region gate。VLM 没有输出下一个 prompt 时，评测不会代替它生成。robot-only anchor 只有在 VLM 已自主输出正确的 next prompt 且当前 subtask 完成 EEF hold/release 后才允许使用。
