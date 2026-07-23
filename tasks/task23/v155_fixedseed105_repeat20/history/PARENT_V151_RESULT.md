# Task23 v151 结果

状态：尚未得到有效 episode。

这条只用于验证 v145 seed105 的 `place popcorn` 早停问题。有效结果必须包含
`summary.tsv`、`run_manifest.json`、main/wrist 视频、sync log 与代码快照；运行后在此文件
记录 seed、Slurm job、stage、视频与 SHA256。

## Attempt 001: 基础设施失败，不计入评测

- Slurm `427687`，seed105，节点 ACD1-14，退出码 `1`。
- 在 VLA server、VLM、环境和 scorer 启动前，v145 继承的 launcher 无条件复制一个不在 shareable
  pack 内的可选脚本 `scripts/build_microwave_deep_eef_targets.py`，因此 `cp` 直接失败。
- 未生成 `run_manifest.json`、episode log、summary 或视频；没有执行任何 rollout step，不能作为
  place-popcorn target 对照的结果。
- v151 已冻结。后继 v152 仅将该可选 snapshot copy 改为存在时复制；评测配置不变。
