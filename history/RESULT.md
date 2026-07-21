# Task23 v145 结果

状态：无有效成功。Attempt 001 是基础设施失败；Attempt 003-004 已完成且均为
`66.7%`，最后一个官方必需 stage 未完成；Attempt 002 仍在运行。

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

## Attempt 002-004: 同版本并行重跑

三条重跑的代码和配置均与 v145 commit 一致，均排除 `ACD1-36`；只改变 seed：

| Attempt | seed | Slurm job | 节点 | 状态 |
| --- | --- | --- | --- | --- |
| 002 | 104 | `427447` | ACD1-6 | 运行中；节点上 rollout 明显慢于 seed105/106，尚未产生有效 summary/video |
| 003 | 105 | `427462` | ACD1-29 | 完成；`66.7%`，前两 stage=Y，`03_Place_Popcorn_Microwave=N` |
| 004 | 106 | `427461` | ACD1-19 | 完成；`66.7%`，前两 stage=Y，`03_Place_Popcorn_Microwave=N` |

这些是同一冻结版本的独立 episode，不是新的代码版本。v145 已在 seed105/106 上稳定
复现到前两 stage，不满足最终成功条件；后续单变量尝试进入独立 v146 仓库。

## 可审计产物

- seed105 main 视频：`task23_v145_remove_cream_place_anchor_seed105_20260721_202500/videos/task23/task23_failure_ep0_seed105.mp4`
- seed106 main 视频：`task23_v145_remove_cream_place_anchor_seed106_20260721_202500/videos/task23/task23_failure_ep0_seed106.mp4`
- 两条 summary 均在相应输出根目录的 `summary.tsv`；官方 scorer commit 固定为
  `62214036103ee8d5fef9b475dd8b344b6e2cfc03`。
