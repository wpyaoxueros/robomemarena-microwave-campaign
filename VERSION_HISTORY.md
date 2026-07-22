# 版本历史

| 版本 | 继承 | 唯一改动 | prompt 权限 | 评分 | 结果 |
| --- | --- | --- | --- | --- | --- |
| v155 | v154 (`b89fe4c`) | 20 个独立 `NUM_TRIALS=1, SEED=105` rollout；评估策略不变 | VLM 自主，oracle=0 | RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03` | 历史有效结果见 `history/RESULT.md` |
| v156 | v155 (`76d8953`) | 五个并行 worker，各四次独立复跑 | VLM 自主，oracle=0 | 同上 | 不完整：4 条有效、8 条 rc=134 abort；详见 `versions/v156_fixedseed105_repeat20_replay/results/` |
| v157 | v156 (`d622bef`) | 调度改为 ACD1-1 单 worker 串行 20 次，非零退出立即停止 | VLM 自主，oracle=0 | 同上 | 预运行已推送，待运行 |

v157 不改变评估、模型、prompt 或评分代码；它只隔离节点稳定性。后续任何评估、模型或
评分代码改动必须建立新的版本目录并记录父 commit，不能覆盖已有版本。
