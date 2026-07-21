# RoboMemArena Task21 v121 Reproduction

这是 Task21 v121 的冻结评测包。它复现的策略是：VLM 自主输出子任务 prompt；EEF hold/release、completed-structure 和机器人姿态 anchor 只控制等待、回退和切换时机，不注入下一个 prompt，也不移动物体。

冻结结果：在 RoboMemArena commit `62214036103ee8d5fef9b475dd8b344b6e2cfc03` 下，seed104 和 seed107 都得到 `stage=100%`、`goal=100%`。每次运行会在输出目录保存实际代码、官方 scorer、BDDL、norm 和 SHA256。

## 使用的 checkpoint

权重不在本仓库中。冻结成功使用的是：

- VLA：`fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338` 的 step `35999`。
- VLM：`task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000_20260701_100519`。
- Norm：仓库内 `assets/norm_repo/norm_stats.json`，SHA256 为 `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`。

运行时必须通过 `.env` 显式传入对应 VLA/VLM 权重位置。

## 不包含的内容

- VLA checkpoint、VLM checkpoint、训练数据和视频。
- 原实验机上的 checkpoint 路径。
- RoboMemArena 官方仓库的副本；运行前必须按固定 commit 准备它。

## 准备

1. 准备已有的 OpenPI、OpenPI inference 和 LIBERO 环境。
2. 使用 `scripts/bootstrap_robomemarena.sh <checkout-dir>` 获取官方 scorer，并保持该 checkout 在固定 commit。
3. 复制 `paths.example.env` 为本机私有 `.env`，填入 VLA、VLM、OpenPI、inference 和 LIBERO 路径。

## 运行

```bash
set -a
source .env
set +a

CUDA_VISIBLE_DEVICES=0,1 SEED=104 bash scripts/run_task21_v121.sh
CUDA_VISIBLE_DEVICES=2,3 SEED=107 bash scripts/run_task21_v121.sh
```

需要两个 seed 并行时，将上面两条命令放在同一台具备四张 GPU 的 Slurm 分配中。每次只跑一个 episode；`SEED=104` 和 `SEED=107` 是冻结成功记录使用的两个种子。

## 自主性约束

本包在启动时固定断言所有 `ORACLE_*` 为 `0`。`MODE=vlm_free`，没有 oracle next-prompt、没有 object anchor。若 VLM 不自己输出下一个 prompt，评测不会代替它生成。

## 可复现性

`scripts/run_task21_v121.sh` 只使用当前仓库内的 launcher/evaluator/config。运行前会校验官方 commit，运行后会保存 `run_manifest.json`、`code_snapshot/` 和 `artifact_sha256.tsv`。不能找到 `task2_26_reference_stage.py` 时会直接失败，绝不回退到旧 scorer。
