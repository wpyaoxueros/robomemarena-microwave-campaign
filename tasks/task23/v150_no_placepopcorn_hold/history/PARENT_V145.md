# 间接父版本审计

- 间接父版本仓库：`https://github.com/wpyaoxueros/robomemarena-task23-v145-eef-anchor-repro`
- 冻结 commit：`ab68f22`
- v145 的有效重跑 seed105、seed106 均为 `66.7%`：前两个官方必需 stage 为真，最后的
  `Place_Popcorn_Microwave` 为假。
- 继承链：`v145 -> v146 -> v147`。v146 改了 place-popcorn EEF 连续命中阈值；v147 只
  解决 norm 自包含，不改这一策略行为。
