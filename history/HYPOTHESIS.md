# Task23 v148 单变量假设

- 父版本：Task23 v147，冻结 commit `b342c5c`。
- 已证实根因：v147 在 code snapshot 阶段无条件复制一个不存在、且从未被 rollout 调用的
  helper，导致 srun 在 4 秒内退出。VLA、VLM、norm 和 official scorer 都未开始。
- 唯一修改：将该 `cp` 包在 `[[ -f ... ]]` 判断中。缺失 helper 不再阻断 snapshot；其余
  所有 snapshot 内容仍会复制。
- 不变项：VLA 权重、VLM checkpoint、官方 scorer、评分 commit、所有 EEF hold/release、
  `place popcorn=1` 和自包含 norm 校验均与 v147 完全一致。
- 预期证据：code snapshot 完成，日志显示同 SHA256 norm asset 被加载且无 fallback，随后才
  允许 episode 产生 stage 结果。
