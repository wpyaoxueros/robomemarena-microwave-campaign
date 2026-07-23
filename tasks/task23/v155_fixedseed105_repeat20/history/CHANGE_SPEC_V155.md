# Task23 v155 变更说明

v155 的唯一用途是检验 v154 的成功 seed `105` 是否稳定。

- 保持 v154 的 VLA/VLM、远端 scorer、hold/release、anchor、prompt 与所有评估配置。
- 不使用 evaluator 的 `NUM_TRIALS=20`，因为它会按 `SEED + ep` 自动递增。
- 改为 5 个 worker 各串行运行 4 次；每次独立进程都固定 `NUM_TRIALS=1`、`SEED=105`。
- 每次运行使用独立 `OUT_ROOT`、独立 manifest、完整视频和 `sync_vlm.log`。
- 没有 oracle prompt 注入，也没有 object anchor。

因此，v155 测量的是同一配置、同一环境 seed 的 20 次重复运行，不是 seed `105..124` 的泛化评测。
