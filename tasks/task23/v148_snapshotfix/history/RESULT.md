# Task23 v148 结果

状态：无有效正式 episode；一次早停诊断已完整保留。

有效结果必须同时具备 `summary.tsv`、`run_manifest.json`、完整 main 视频、wrist 视频以及
启动日志中无 norm fallback 的证据。每个 episode 的 seed、Slurm job、stage、goal 审计值、
视频路径和 SHA256 都会在这里追加。

## 诊断尝试 001

- Slurm：`427507`，实际 seed=`104`（目录名沿用旧的 `seed105`，以
  `run_manifest.json` 和启动日志为准）。
- 远端评分：`62214036103ee8d5fef9b475dd8b344b6e2cfc03`；VLA runtime norm 与
  checkpoint asset 已逐字节校验通过，没有 fallback。
- 过程：VLM 从 `t=0` 到 `t=65` 均自主输出 `open microwave`，所有 `ORACLE_* = 0`。
  EEF 到开门 target 的距离没有收敛（约 `0.42m`），门 joint 只短暂达到 `0.02128` 后回落，
  未触发 hold 或新版 official stage。
- 处理：在 7 分 51 秒、`t=65` 时主动取消，避免将明显的开门动作失败浪费到 2000 step；
  因此没有 `summary.tsv` 结果和完整视频，debug 图片与日志保留在
  `/data/user/zzhang510/hlei573_borrow_outputs/microwave_task23_continuations/task23_v148_snapshotfix_seed105_20260721_205314`。
- 根因：`run_manifest.json` 和 `logs/shell_vars.before_eval` 都记录
  `vla_training_prompt_template_file=""`。VLA 收到短标签 `open microwave`，没有收到
  35999 训练时的完整 Task23 语义 prompt。下一版本只修复该输入接口；本版本不改代码。
