# Task23 v154 变更说明

## 目标

验证 v153 的无最终 anchor 路径在 20 个指定 seed 上的表现；修复 tmux 提交层丢失
`NUM_TRIALS`/`SEED` 的问题。

## 唯一行为改动

继承 v153 的 release-anchor 配置：

```text
released=pick popcorn, next=place popcorn, frame_idx=165
```

因此 VLM 自主输出 `place popcorn` 后，VLA 从真实 pick 结束状态继续执行，不读取或
应用该训练轨迹 anchor。v154 不改动这项评测行为。

## 提交器修复

`submit_zzhang510.sh` 在 tmux 的内层 `srun` 命令中显式传递当前 `NUM_TRIALS` 和 `SEED`。
这只修复 shell 环境传播，不改变 evaluator、模型、prompt、anchor、hold 或评分规则。

## 保持不变

- v153 的 VLM、VLA、短 primitive prompt、`replan=5`、`max_steps=2000`。
- VLM 自主 prompt 与全部 `ORACLE_*=0`。
- `open microwave -> pick cream` 和 `place cream -> pick popcorn` 的 robot-only anchor。
- `place popcorn` 不参与 EEF target/连续 hold。
- RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03` 评分与三项必需 stage。
