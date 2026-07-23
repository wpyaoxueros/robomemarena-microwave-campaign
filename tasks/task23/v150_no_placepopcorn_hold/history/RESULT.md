# Task23 v150 结果

## Run 1: seed104, 1 episode

- 状态：完成但失败，Slurm `427612`，耗时 `370.19s`。
- 评分：RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03`，stage-only，
  `Close Microwave` optional。
- 输入：原始 VLA 35999（由本地 `inputs.env` 注入，不在仓库记录路径）、Task23 v144
  VLM `checkpoint-400`、完整 Task23 VLA 训练 prompt 模板。
- norm：原始 norm SHA256 为
  `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`；运行时和
  checkpoint 内资产均直接加载，没有 fallback。
- 自主性：所有 `ORACLE_*` 均为 `0`。VLM 从 `t=0` 到结束始终输出 `open microwave`；
  没有 oracle next-prompt 注入，也没有 object anchor。
- v150 唯一行为改动已生效：end-pose target 配置中不含 `place popcorn`，hold consecutive
  配置中也不含该子任务；日志中没有 `place popcorn` hold。

结果：`stage_score=0.0%`、`stage_success=0/1`、`goal_success=0/1`。

| Official stage | 结果 |
| --- | --- |
| Open Microwave | N |
| Place Cream Microwave | N |
| Place Popcorn Microwave | N |

失败发生在第一阶段，不能归因于已取消的 `place popcorn` target：`open microwave` 最小
EEF 距离为 `0.15777`，需要 `<=0.10500`；door joint 全程约为 `0`，没有发生开门 hold 或
后续 prompt 切换。因此这条只证明“取消 place-popcorn target 不会造成额外干预”，并未覆盖
place-popcorn 的执行路径。

本地输出 run id：`task23_v150_no_placepopcorn_hold_20260721_213411`。完整输出包含
`summary.tsv`、`run_manifest.json`、main/wrist mp4、sync log、prompt trace 与代码快照。

| 证据 | SHA256 |
| --- | --- |
| summary.tsv | `9587df36254242b161d809e9f881478de7e88ca61706ca8f1e24d22432a5f95e` |
| run_manifest.json | `9a2b2519963a4343d190ccdca1a2c50674d9c784b26247852de5fe7a911a67ce` |
| sync_vlm.log | `83ba79f9dcc88cd5d5ead5a9ca75ff77c68b6655a8dffb2f953e2e7e4ab80257` |
| main video | `adb7d79669e480c24a0b6a7c36d0eb907a2cc30cdcca9ef34e4742d287f695ab` |
| wrist video | `73b49ee1ea43e9327b21b941bfba07b00f20471f3602a9dda2f5b326c269ce69` |
