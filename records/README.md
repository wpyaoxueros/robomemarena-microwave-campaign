# 实验总账

这个目录是本仓库所有评测和复现实验的唯一总账入口。原始视频、日志和模型权重仍可在各账号的输出根目录中，但一条实验只有同时写入这里、通过校验并 push 后，才算被记录。

## 记录状态

- `SUCCESS`：该条记录的既定成功口径满足。是否能作为当前正式结果由 `qualification` 决定。
- `FAILED`：有效 rollout 已完成，但没有达到该条预先声明的成功口径。
- `PARTIAL`：至少有一条有效官方 episode，但任务在目标试次数前停止；必须保留已完成的分子/分母，不能写成 `0/20` 或完整结果。
- `REPORTED`：历史指标曾被汇报，但本轮尚未恢复足以核验该指标的逐 episode 原始证据。
- `INVALID`：启动、环境、代码、评分器或聚合错误；不计入成功率分母。
- `IN_PROGRESS`：已经提交但还没有最终 summary；不能汇报成功率。

`qualification` 用来避免把不同远端版本混在一起：

- `current_strict`：当前远端 scorer、完整执行契约、`POST_GOAL_STEPS=200` 都已验证。
- `latest_pinned`：在记录时为远端最新提交，但不自动等价于当前正式结果。
- `historical_pinned`：旧 scorer 下有效，保留作历史基线。
- `reported_unrecovered`：历史指标已知，但逐 episode 原始 summary 尚未恢复；不得用于当前严格比较。
- `diagnostic`：只用于定位行为或失败原因。
- `excluded`：结果存在，但因代码/环境/评分契约问题不能计入。
- `legacy_termination`：scorer 已固定，但 rollout 仍使用旧的终止/等待策略，不满足当前 `POST_GOAL_STEPS=200` 契约。
- `pre_correction`：记录了 `POST_GOAL_STEPS=200`，但 2026-07-25 修复前的 adapter 未实际执行该策略；只能保留为证据。

## 每次实验的强制流程

1. 启动前写 `IN_PROGRESS` 记录，注明版本、VLA/VLM、norm、scorer、seed、入口脚本、输出根和目标成功口径。
2. 结束后只追加一条新记录，不修改旧记录；完整、部分、失效和历史汇报必须分别记录为 `SUCCESS`、`FAILED`、`PARTIAL`、`INVALID` 或 `REPORTED`。
3. 在同一个提交中更新 `EXPERIMENT_LEDGER.jsonl` 和 `EXPERIMENT_LEDGER.md`，运行校验，再 push。
4. 提交标题必须以 `SUCCESS:`、`FAILED:`、`INVALID:` 或 `IN_PROGRESS:` 开头，且必须含任务号和版本号。例如：`SUCCESS: task23 v155 fixed-seed105 15-of-20`。

任何没有总账行、没有 scorer commit、没有 VLA/VLM/norm 路径或没有原始 evidence 路径的结果，都不能作为可复现实验结果汇报。外层 `summary.tsv` 为空时，必须扫描每个 `ep*/sync_vlm.log` 的 `[OFFICIAL_SCORE]`；不得把“尚未生成聚合表”误报为 `0/20`。

## 校验

```bash
python3 scripts/validate_experiment_ledger.py
python3 scripts/validate_experiment_ledger.py --check-local
```

第二条命令在本机检查总账所指向的本地入口、summary/manifest 和输出路径是否仍可访问。历史 `reported_unrecovered` 行会明确保留缺失状态，不会被伪装成可复现证据。

借用账号的输出根可能是账号私有目录。跨账号总账应先运行普通校验，再分别进入每个 `submit_account` 的 shell 验证其私有输出；不要因为 `hlei573` 无法 `stat` `xiangqim` 或 `zzhang510` 的私有目录，就把已在 owner shell 中核验的记录误报为不存在。`--check-local` 会把这种情况明确报为 `inaccessible`，不会再崩溃。
