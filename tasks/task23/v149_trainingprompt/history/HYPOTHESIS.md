# Task23 v149 单变量假设

- 父版本：Task23 v148，冻结 commit `1c7295d`。
- 已证实根因：v148 的 `run_manifest.json` 与 shell 环境都记录
  `VLA_TRAINING_PROMPT_TEMPLATE_FILE=""`。VLA 因而只收到短标签 `open microwave`，在
  `t=0..65` 无法收敛到开门 target；VLM 输出本身是正确的。
- 唯一修改：默认加载经过来源 hash 固定的完整 Task23 训练 prompt 模板，并把实际模板复制到
  每个 output snapshot。环境显式覆盖该变量时仍会被记录和校验。
- 不变项：VLA 权重、VLM checkpoint、官方 scorer、评分 commit、所有 EEF hold/release、
  `place popcorn=1` 与自包含 norm 校验均与 v148 完全一致。
- 预期证据：日志出现 `[VLA_TRAINING_PROMPT_TEMPLATE]`，开门 EEF 距离开始收敛，并在
  不使用 oracle/object anchor 的前提下产生正式 stage 结果。
