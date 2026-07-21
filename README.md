# RoboMemArena Task23 v155 Fixed-Seed Repetition

这是 Task23 的一个不可变评测版本仓库。每个版本一个仓库；不覆盖之前版本。

## 版本结论

- 父版本：Task23 v154 commit `b89fe4c`，保留其全部评估行为。
- 目标：同一个环境 seed `105` 独立执行 20 次，检验单 seed 是否稳定。
- 不能用 `NUM_TRIALS=20`，因为 evaluator 会自动执行 `seed = SEED + ep`。v155 改为
  5 个 worker 各串行 4 次，每次独立调用均为 `NUM_TRIALS=1`、`SEED=105`。
- VLM 负责输出所有子任务 prompt；没有 oracle next-prompt 注入，没有 object anchor。
- 评分固定到 RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03`。Close Microwave
  仍是审计项；Task23 成功按三个必需 stage 全完成判定。
- 已完成固定 seed105 的 20 条有效 episode：`15/20 = 75.0%` stage-only success，平均
  stage score `88.3%`。完整组成和四次独立基础设施中止记录见 `history/RESULT.md`。

运行结果、视频名和外部产物哈希记录在 `history/RESULT.md`；不要根据仓库名推断成功或失败，
必须以该文件、每条 `summary.tsv` 和视频为准。

## 内容

- `run_task23_v155.sh`：不改 v154 行为的单 episode 入口。
- `scripts/run_fixed_seed_worker.sh`：一个 worker 串行执行四次 seed105。
- `submit_fixedseed105_zzhang510.sh`：提交一个 worker；worker `0..4` 合计 20 次。
- `inputs.env.example`：外部模型、数据、环境路径接口。仓库不写入 checkpoint
  的内部绝对路径。
- `config/`：本版本所有 hold target、passage、tolerance 和 release-anchor 配置。
- `evaluators/` 与 `scripts/`：本次运行使用的评测包装代码快照。
- `history/`：继承关系、假设、提交记录和最终结果。

## 复现

1. 将 `inputs.env.example` 复制为 `inputs.env`，填入本机路径。
2. 确认 `ROBOMEMARENA_REMOTE_ROOT` 是 commit
   `62214036103ee8d5fef9b475dd8b344b6e2cfc03`。
3. 从 `zzhang510` 的 shell 为 worker `0..4` 分别执行：

```bash
WORKER_ID=0 INPUTS_FILE=/absolute/path/to/inputs.env bash submit_fixedseed105_zzhang510.sh
```

每次会创建独立输出目录；每条 episode 都会保存代码快照、远端评分脚本、manifest、日志和视频。

## 版本纪律

发现新假设时，创建一个新的 GitHub 仓库和新的版本号；不要在本仓库修改配置后
冒充 v154。该规则避免历史成功代码和后续尝试混淆。
