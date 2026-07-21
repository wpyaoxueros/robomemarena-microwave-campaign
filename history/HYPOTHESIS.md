# Task23 v146 单变量假设

- 父版本：Task23 v145，冻结 commit `ab68f22`。
- 已观察现象：v145 的 seed105/106 都完成 `01_Open_Microwave` 和 `02_Place_Cream_Microwave`，官方评分均为 `66.7%`；第三个 `03_Place_Popcorn_Microwave` 未完成。
- 关键 trace：seed105 在 `place popcorn` 首次进入 EEF 目标容差后，仍要求连续 3 次命中才会开始 hold；随后输出反复回退，未在首次正确接近时进入 release 后的放置动作。
- 单一假设：`place popcorn` 的连续命中条件过严，错过了短暂但有效的首次接近窗口。
- 唯一修改：仅将 `ENDPOSE_HOLD_CONSECUTIVE_BY_SUBTASK_JSON` 中 `place popcorn` 从 `3` 改为 `1`。VLM checkpoint、VLA 35999、官方 scorer、评分 commit、hold 时间、prompt guard、release anchors 和其它子任务阈值完全不变。
- 预期证据：在 VLM 自主输出 `place popcorn` 后，首次 EEF 进入 0.06m 容差即开始 hold/release，并使 `03_Place_Popcorn_Microwave=true`。
- 自主性分类：VLM 生成当前和下一子任务 prompt；所有 `ORACLE_* = 0`，没有 object anchor。保留的 robot-only anchor 仅在 VLM 已输出下一 prompt 且当前子任务完成 EEF hold/release 后执行。
