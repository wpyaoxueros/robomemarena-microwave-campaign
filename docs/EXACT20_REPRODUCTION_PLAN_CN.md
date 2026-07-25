# 18 任务 Exact-20 复跑计划

## 目标

对仓库覆盖的 18 个任务 `1,2,3,6,7,10,12,13,14,16,18,20,21,22,23,24,25,26` 各生成一条可复现的 20 episode canonical 结果。

固定原则：

1. VLA 固定为 `fullvlm_v2_robomemarena_noflip_v2.../35999`，并记录 checkpoint 内自包含 norm 的 SHA256。
2. 每个任务复用其已冻结的本地 rollout runtime、VLM checkpoint、prompt/hold/replan 配置；不能把上游 generic evaluator 当成运行时替代品。
3. CSR、TSR、stage 和 BDDL 只由远端 RoboMemArena `d9f83ac5182e25ad7f0a301a77a0b667f2392df1` 的 `task2_26_reference_stage.py` 计算；scorer SHA256 必须是 `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`。
4. 每个新版本先做 1ep contract gate：确认 VLA/VLM/norm、官方 scorer、seed、prompt guard、`POST_GOAL_STEPS=200`（若该任务使用 goal 后观察）和输出 summary 都真实生效。通过后才扩展到 20ep。
5. 结果只以逐 episode 的有效 official summary 为准。空文件、native abort、generic driver、缺 scorer 或 fallback 都不计入分母。
6. 每次提交前先写 `records/EXPERIMENT_LEDGER.jsonl` 的 `IN_PROGRESS`；结束后追加 `SUCCESS`、`FAILED`、`PARTIAL` 或 `INVALID`，校验并 push。旧记录不覆盖。

## 当前基线（2026-07-25）

下表的“可用”仅表示已有真实输出，不表示已经满足本计划的 canonical strict 口径。

| Task | 当前有效条数 | 当前 stage 成功 | 当前状态 | 本计划动作 |
| ---: | ---: | ---: | --- | --- |
| 1 | 20 | 14/20 | historical pinned | 用本地原 runtime + d9 scorer 重跑 20。 |
| 2 | 20 | 20/20 | 7 月 25 日 d9 分片 + repair6，已完成 | 补登记并复核终止控制；不再误写成 0。 |
| 3 | 20 | 11/20 | 7 月 25 日 d9 poolstep 分片 + 5 条补片，已完成 | 补登记并复核终止控制；不再误写成 0。 |
| 6 | 20 | 17/20 | pre-correction | 用冻结 counting runtime 重跑 20。 |
| 7 | 19 | 10/19 | guarded fixed-seed 新版本，进行中 | 补完第 20 条，提交结果记录；随后决定是否扩展多 seed。 |
| 10 | 20 | 2/20 | pre-correction | 用冻结 Task10 runtime 重新 gate 后跑 20。 |
| 12 | 9 | 6/9 | historical partial | 补为 canonical 20。 |
| 13 | 9 | 5/9 | historical partial | 补为 canonical 20。 |
| 14 | 3 | 0/3 | pre-correction partial | 先修 callback contract，再跑 20。 |
| 16 | 20 | 17/20 | pre-correction | 用非 oracle 的冻结 runtime 重新 gate 后跑 20。 |
| 18 | 6 | 5/6 | historical partial | 补为 canonical 20。 |
| 20 | 13 | 7/13 | pre-correction partial | 用冻结微波炉 runtime + d9 scorer 跑 20。 |
| 21 | 0 | - | 20 条均 invalid | 先修 runtime/summary contract，再跑 20。 |
| 22 | 0 | - | 本窗口无可审计 rollout | 先选择非 oracle 版本并做 1ep gate。 |
| 23 | 0 | - | 本窗口无可审计 rollout | 先选择 VLM 生成 prompt 的版本并做 1ep gate。 |
| 24 | 0 | - | 本窗口无可审计 rollout | 先选择 VLM 生成 prompt 的版本并做 1ep gate。 |
| 25 | 8 | 2/8 | historical partial | 补为 canonical 20。 |
| 26 | 20 | 5/20 | pre-correction | 用冻结 runtime + d9 scorer 重新 gate 后跑 20。 |

## 调度顺序

1. 完成正在运行的 Task7；仅补缺失 episode，不覆盖已有 19 条。
2. 将已完成的 Task2/Task3 25 号 d9 分片补入总账，明确它们的终止控制和版本，不再重跑或与其它 Task2/3 分片混合。
3. 处理已有原 runtime 且只差数量的 `12,13,18,25`。每个任务做 1ep contract gate 后，按缺口并行补到 20。
4. 处理已有 20 条但不符合 current contract 的 `1,6,10,16,26`，每个任务建立新的 canonical run，不混入旧分母。
5. 处理接口/运行时未通过的 `14,21`。先单独修正并提交 contract test，gate 有 valid official summary 后才投入 20ep。
6. 最后处理微波炉 `20,22,23,24`。必须满足：VLM 自主输出 prompt、无 oracle prompt 注入、无 object anchor；本地 hold/release 只辅助等待或防回退，不能替 VLM 写下一 prompt。

## 每个任务的交付物

每个 canonical run 必须包含：

- Git commit、冻结 launcher/evaluator/scorer snapshot 和 manifest。
- VLA、VLM、norm 的完整路径与 SHA256。
- seed 规范、GPU topology、prompt/hold/replan/goal 后观察参数。
- 20 条逐 episode official summary、聚合表、成功和最高 stage 视频。
- `records/EXPERIMENT_LEDGER.jsonl` 的开始和结束记录，以及一次通过的 ledger 校验。

## 判定

完成不是“曾出现过一次成功视频”，而是 canonical run 恰有 20 条有效 episode；成功率为该 run 的 `stage_successes / 20`，goal 结果另列审计。历史、诊断、旧 scorer、pre-correction、invalid episode 永远保留，但不得混进 canonical 分母。
