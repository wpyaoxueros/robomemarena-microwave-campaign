# Task23 v147 可复现性假设

- 父版本：Task23 v146，冻结 commit `a7f7a8a`。v146 没有提交 episode：共享 Hugging Face
  cache 不支持 ACL，借用账号无法读取它。
- 根因：VLA checkpoint 没有与训练 repo asset id 匹配的 norm file；policy 会对不可读的
  runtime norm 走隐式 checkpoint/data-config fallback，无法保证路径与数值都一致。
- 唯一修改：把 original norm 的同一 SHA256 文件作为本仓库的 runtime asset，并安装到
  VLA checkpoint 的同名 assets 目录。启动器会比较两个文件；任何缺失或内容不一致都会
  在 rollout 之前退出。
- 不变项：VLA 权重、VLM checkpoint、官方 scorer、评分 commit、所有 EEF hold/release
  逻辑与 v146 完全一致，包括 `place popcorn=1`。
- 预期证据：日志直接显示 checkpoint asset norm 已加载；不出现 `Checkpoint assets missing`
  或 `Falling back`；才允许将 episode 计入结果。
