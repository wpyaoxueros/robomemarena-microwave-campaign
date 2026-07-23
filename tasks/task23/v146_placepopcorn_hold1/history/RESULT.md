# Task23 v146 结果

状态：未提交正式 episode，已由 v147 替代。

## 环境预检阻断

- `zzhang510` 可读取 v146 代码、VLA checkpoint、VLM checkpoint 和输出目录，但无法读取
  原始 Hugging Face norm cache。
- 该 cache 挂载不支持 ACL；因此不能用“补 ACL”解决，也不应让 policy 落回 checkpoint
  缺失 asset 后的隐式 fallback。
- 该阻断发生在 Slurm 预检之前，没有运行 rollout、没有生成 episode 结果，也不构成
  v146 的策略失败。
- 后继 v147 只解决这个可复现性问题：使用完全相同 SHA256 的 norm 文件，放入 package
  runtime asset 并安装到原 VLA checkpoint 的同名 `assets/<asset_id>/` 下，启动时强制
  校验 asset 存在。

有效结果必须同时具备 `summary.tsv`、`run_manifest.json`、完整 main 视频及 wrist 视频。
每个 episode 的 seed、Slurm job、stage、goal 审计值、视频路径和 SHA256 都会在这里追加。
