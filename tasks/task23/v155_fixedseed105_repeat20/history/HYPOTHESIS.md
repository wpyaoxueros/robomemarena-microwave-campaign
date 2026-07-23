# Task23 v152 可执行单变量对照

- 继承：v151 的行为配置和 v145 seed105 的短 primitive prompt 路径。
- 唯一评测行为差异：Task23 的 `place popcorn` 没有 end-pose target，也没有 consecutive hold。
- 唯一基础设施差异：可选的 `build_microwave_deep_eef_targets.py` 不在 pack 中时跳过快照复制，
  防止模型启动前 `cp` 退出。它不进入 evaluator 或 rollout。
- 不变项：VLM checkpoint、原始 VLA 35999、原始 cache norm repo、seed105、scorer commit、
  replan、VLM prompt 自主性、anchor、hold/release、passage、所有 `ORACLE_*`。
- 成功判据：至少复刻 v145 的开门与 cream stage；之后验证 popcorn 不会被浅层 EEF target hold。
