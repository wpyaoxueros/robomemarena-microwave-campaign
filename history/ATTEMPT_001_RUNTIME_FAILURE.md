# Attempt 001 运行时失败审计

这是一次基础设施失败，不是行为评测失败。

- 节点：`ACD1-36`
- Slurm：`427314`，exit code `134` / `SIGABRT`
- 失败位置：`place cream` rollout 中，VLM Python 进程中止
- 完成情况：真实开门、`pick cream` EEF hold/release 已发生；未写出远端评分和视频
- 处理：排除该节点，使用相同 v145 commit 在新的 GPU 节点重跑

本文件与 `history/RESULT.md` 一起构成 v145 的不可变运行历史。
