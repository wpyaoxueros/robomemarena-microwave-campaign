# RoboMemArena Task23 v145 Reproduction

这是 Task23 的一个不可变评测版本仓库。每个版本一个仓库；不覆盖之前版本。

## 版本结论

- 继承版本：Task23 v144。
- 唯一修改：删除 `pick cream -> place cream` 的 robot-only frame-40 release anchor。
- VLM 负责输出所有子任务 prompt；没有 oracle next-prompt 注入。
- 没有 object anchor 或物体瞬移。
- 评分固定到 RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03`。
- `Close Microwave` 是审计项；Task23 的成功按最新远端必需 stage 全完成判定。

运行结果和视频会在本次 episode 结束后登记到 `history/RESULT.md`。不要根据
仓库名推断成功或失败，必须以该文件、`summary.tsv` 和视频为准。

## 内容

- `run_task23_v145.sh`：固定本版本开关的入口。
- `inputs.env.example`：外部模型、数据、环境路径接口。仓库不写入 checkpoint
  的内部绝对路径。
- `config/`：本版本所有 hold target、passage、tolerance 和 release-anchor 配置。
- `evaluators/` 与 `scripts/`：本次运行使用的评测包装代码快照。
- `history/`：继承关系、假设、提交记录和最终结果。

## 复现

1. 将 `inputs.env.example` 复制为 `inputs.env`，填入本机路径。
2. 确认 `ROBOMEMARENA_REMOTE_ROOT` 是 commit
   `62214036103ee8d5fef9b475dd8b344b6e2cfc03`。
3. 从 GPU Slurm allocation 内执行：

```bash
bash run_task23_v145.sh
```

启动前脚本会校验远端 commit、必要的 VLM/VLA/checkpoint、评测代码和配置。每次
运行都会把实际代码和评分脚本快照复制到输出目录并生成 SHA256 清单。

## 版本纪律

发现新假设时，创建一个新的 GitHub 仓库和新的版本号；不要在本仓库修改配置后
冒充 v145。该规则避免历史成功代码和后续尝试混淆。
