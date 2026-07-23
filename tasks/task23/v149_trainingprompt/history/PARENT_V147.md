# 父版本审计

- 父版本仓库：`https://github.com/wpyaoxueros/robomemarena-task23-v147-selfcontained-norm-repro`
- 父版本冻结 commit：`b342c5c`
- v147 的 1-GPU Slurm 预检成功；正式 job 在 VLA/VLM 启动前因过期 snapshot helper 失败。
- v148 只修复该 snapshot 的存在性判断；不改变模型、norm 数值或 rollout 行为。
