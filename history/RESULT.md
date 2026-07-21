# Task23 v145 结果

状态：等待同版本重跑。

## Attempt 001: 运行时无效

- seed 104，1 episode，Slurm job `427314`，节点 `ACD1-36`。
- rollout 已完成真实开门、`pick cream` EEF hold/release，并进入 `place cream`。
- 随后 VLM Python 进程收到 `SIGABRT`，Slurm exit code `134`；没有 `summary` 结果，
  没有完整视频。
- 该退出没有 Python traceback，也没有 stage scorer 输出，因此它不是策略失败，
  也不能用来判断 v145 的成功率。
- 下一次尝试只排除 `ACD1-36`，评测代码、模型标签、seed、评分 commit 和 v145 配置
  保持完全相同。

最终有效结果只能在 `summary.tsv`、完整视频和 `run_manifest.json` 全部生成后追加到
此文件。每一次重跑都保留独立的输出目录和 SHA256 清单。
