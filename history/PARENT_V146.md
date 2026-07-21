# 父版本审计

- 父版本仓库：`https://github.com/wpyaoxueros/robomemarena-task23-v146-placepopcorn-hold1-repro`
- 父版本冻结 commit：`a7f7a8a`
- v146 未运行 rollout：借用账号无法读取原始 Hugging Face norm cache，且该挂载不支持 ACL。
- v147 继承 v146 的所有策略行为，仅解决 norm 自包含与无 fallback 校验。
