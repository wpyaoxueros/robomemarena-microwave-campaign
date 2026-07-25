# 17 任务 Stage-Only 原始回退基线

这是当前实验仓库的第一优先回退点。后续版本如果出现明显退化，先回退到
Git tag `baseline-stageonly-17tasks-199of340-20260726`，再从该版本继续排查。

## 固定结果

- 任务集合：`1, 2, 3, 6, 7, 10, 12, 13, 14, 16, 18, 20, 21, 23, 24, 25, 26`
- 排除任务：`22`
- 每个任务固定按 `20` 个 episode 计入。
- 总分母：`17 * 20 = 340`
- Stage-only 成功：`199`
- TSR：`199 / 340 = 58.5294%`

单个 episode 只有在全部必需 stage 完成时才计为成功。这里不使用
`goal_success` 或旧 BDDL goal 代替 TSR。微波炉任务的最后关门 stage 按对应
冻结包的约定作为 optional stage。

| Task | Stage-only 成功 |
| ---: | ---: |
| 1 | 14/20 |
| 2 | 20/20 |
| 3 | 11/20 |
| 6 | 17/20 |
| 7 | 11/20 |
| 10 | 2/20 |
| 12 | 10/20 |
| 13 | 14/20 |
| 14 | 2/20 |
| 16 | 17/20 |
| 18 | 19/20 |
| 20 | 8/20 |
| 21 | 11/20 |
| 23 | 15/20 |
| 24 | 14/20 |
| 25 | 9/20 |
| 26 | 5/20 |
| **合计** | **199/340** |

## 口径边界

这是“各任务已冻结成功版本”的组合回退基线，不是把 17 个任务全部用同一
最新远端 scorer 重新跑出的 strict 基线。各任务使用其归档运行实际固定的
scorer 和 runtime；因此后续比较必须同时注明 scorer commit、runtime commit
和 seed 口径。

CSR 需要从 340 个 episode 的 stage score 逐条聚合，不能由 `199/340` 推算。
在逐条审计完成前，本基线只固定 TSR，不填写猜测的 CSR。

## 回退方法

```bash
git fetch origin --tags
git switch --detach baseline-stageonly-17tasks-199of340-20260726
```

需要继续开发时，从 tag 新建分支：

```bash
git switch -c recover/from-stageonly-199 baseline-stageonly-17tasks-199of340-20260726
```

机器可读清单见
`records/BASELINE_17TASK_STAGEONLY_199OF340.json`。
