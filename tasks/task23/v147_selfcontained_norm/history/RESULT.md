# Task23 v147 结果

状态：无有效 episode。Attempt 001 在 rollout 前失败，原因是代码快照步骤引用了包内不存在的
辅助脚本；该错误与策略、VLA、VLM、norm 或官方 scorer 无关。

## Attempt 001: 打包完整性失败

- 提交账号：`zzhang510`，无显式 Slurm account；1-GPU 同 shell 预检 `427498` 已通过。
- 正式 job：`427500`，节点 `ACD1-6`，exit code `1`，耗时 4 秒。
- 失败命令：`cp scripts/build_microwave_deep_eef_targets.py code_snapshot/`。
- 根因：该 helper 在此 package 及父版本实际运行链中都不存在，也不被 rollout 调用；它只是
  过期的 snapshot 列表项，却被当作必需文件。
- 没有启动 VLA/VLM，没有生成视频、summary 或 stage score。因此不能把它解释为策略失败。
- 后继 v148 仅将该 snapshot copy 改为“存在时复制”；所有评测行为、norm 校验和模型输入不变。

有效结果必须同时具备 `summary.tsv`、`run_manifest.json`、完整 main 视频、wrist 视频以及
启动日志中无 norm fallback 的证据。每个 episode 的 seed、Slurm job、stage、goal 审计值、
视频路径和 SHA256 都会在这里追加。
