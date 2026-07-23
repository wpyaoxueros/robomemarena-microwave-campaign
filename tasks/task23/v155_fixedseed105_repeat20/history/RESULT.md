# Task23 v155 结果

状态：完成。

## 最终口径

- 固定环境 seed：`105`
- 有效 single-episode rollout：20
- scorer commit：`62214036103ee8d5fef9b475dd8b344b6e2cfc03`
- 成功定义：三个必需 stage 全完成；`Close Microwave` 为 optional 审计项。
- VLM 负责输出 prompt；所有 `ORACLE_*` 开关均为 0，未使用 object-moving anchor。

## 20 条有效结果

| 结果 | 条数 | 占比 |
| --- | ---: | ---: |
| 三个必需 stage 全完成 | 15 | 75.0% |
| 完成两个必需 stage（66.7%） | 4 | 20.0% |
| 未完成必需 stage | 1 | 5.0% |

- stage-only success：`15/20 = 75.0%`
- 平均 stage score：`88.3%`
- 15 条 stage-only success 的 episode summary 同时记录为 `goal_success=1`；该字段仅作审计，主结论仍以上述 stage-only 口径为准。

## 有效 episode 组成

| 来源 | 4 条结果（stage score） |
| --- | --- |
| worker0 | 100, 100, 100, 66.7 |
| worker1 | 0 |
| worker2 | 100, 66.7, 100, 100 |
| worker3 | 100, 100, 100, 100 |
| worker4 | 66.7, 100, 100, 100 |
| replacement slot1 | 100 |
| replacement slot3 | 100 |
| replacement slot4 | 66.7 |

每条有效 episode 都有独立 `summary.tsv`、`run_manifest.json`、main/wrist 视频和
`sync_vlm.log`。外部输出目录与模型路径不公开写入本仓库；复现时由未提交的 `inputs.env`
提供，代码、参数和 scorer 快照均在本仓库中固定。

## 不计入 20 条有效结果的基础设施中止

以下四次没有写出有效 episode summary，均以 `rc=134` 的 C++ core abort 结束，因此不混入
20 条有效 rollout 的分母：worker1 的三次重跑，以及 replacement slot2。前三次发生在
`ACD1-58` 的首次 VLM generation；slot2 发生在 `ACD1-40` 的约 t=350，说明该中止不能归因
为单一节点。原始日志保留供单独诊断，但不作为行为失败或成功统计。
