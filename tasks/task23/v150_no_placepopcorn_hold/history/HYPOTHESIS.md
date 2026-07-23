# Task23 v150 单变量假设

- 父版本：Task23 v149，冻结 commit `f9b9ae7`。
- 失败证据：v145 在 `t=662` 已接收 VLM 自主输出的 `place popcorn`，并没有 oracle 注入；
  但 `t=718` EEF 距浅层 `place popcorn` target 仅 `0.05118m` 时就被 EEF hold，随后物体
  未进入 microwave heating region，第三 stage 失败。
- 唯一修改：从 Task23 的 hold target 配置中删除 `place popcorn`。因此该子任务不会形成
  EEF streak、hold 或 release；官方 stage scorer 不受影响，仍只在物体真正进入目标区域时
  记第三 stage。
- 不变项：完整 35999 prompt、VLA/VLM 权重、官方 scorer、评分 commit、open/pick/place-cream
  的 EEF hold/release、`pick popcorn` 的两次 passage 与 30-step hold、自包含 norm 均保持。
- 预期证据：日志中不出现 `ENDPOSE_HOLD_START ... subtask=place popcorn`；VLA 在该 prompt 下
  持续执行，直到第三 stage 成功或 episode 终止。
