# 运行逻辑与远端评分边界

本仓库的复现分为两层，不能互相替换。

## 运行层：本仓库控制

本仓库负责 VLM/VLA rollout 的运行逻辑，包括 prompt 轮询、prompt guard、hold/release、replan、视频、日志和结果目录。

对于 Task7 这类计数任务，`eval_counting_autonomous_guarded_d9f83ac.py` 的规则是：

1. VLM 自己产生 raw prompt；不由代码生成下一步 prompt。
2. 若 VLM 提前切到 pour，guard 继续保持已接受的 pick prompt，直到前置 stage 真完成。
3. 若 VLM 输出回退 prompt，guard 保持当前已接受的 prompt。
4. stage 完成后只强制下一次 VLM 轮询，不替 VLM 指定该轮输出。

因此它是运行时的前进/回退保护，不是 oracle prompt 注入。

禁止把远端通用 `eval_fullvlm26_async_vlm_vla.py` 直接替换本仓库已经验证过的任务运行层。这样会移除 guard、hold/release 等复现行为，即使 VLA、VLM、seed 和 scorer 都不变，轨迹也会改变。

## 评分层：远端 RoboMemArena 控制

远端代码只负责官方 stage/BDDL 判定和 CSR/TSR 统计。每个有效 run 必须固定并记录：

- `remote_commit`
- `official_scorer_sha256`
- 官方 `task2_26_reference_stage.py`

Task7 当前固定为 RoboMemArena `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`，scorer SHA 为 `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`。

## 可复现运行包

Task7 的每个 episode 在启动前 materialize 一个 execution pack：冻结的本仓库 runtime wrapper 原样复制，并将其 `source/RoboMemArena_d9f83ac` 链接到已校验的官方 source checkout。运行 manifest 必须同时包含：

- `evaluator_entrypoint_sha256`：本仓库运行层的 hash；
- `official_scorer_sha256`：远端评分层的 hash；
- VLA checkpoint、norm SHA、VLM checkpoint/model SHA；
- seed、replan、VLM interval、oracle/object-anchor 状态。

只有这两类 hash 都匹配时，结果才可称为同一路径复现。
