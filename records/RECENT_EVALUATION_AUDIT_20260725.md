# 2026-07-24 晚至今 Git 运行审计

## 范围

本文件只统计本仓库在 `2026-07-24 18:00 +08:00` 至本次审计时实际发起、恢复或记录的运行。范围起点是提交 `27684ec`，当前代码端点是 `51c41d0`。

不把更早的历史成功包、旧视频或旧训练结果当成“昨晚到现在的复跑结果”。历史包在这一时间窗内只作为运行输入或代码快照；只有本表列出的外部输出根才是本轮实际产生的 rollout 证据。

所有条目共用的 VLA 与 norm：

- VLA：`/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`
- norm：`/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`
- norm SHA256：`4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`

每个任务的完整 VLM checkpoint 绝对路径在 [LOCAL_ASSET_REGISTRY.md](../evaluation_campaigns/all18_repo_direct_exact20_20260725/LOCAL_ASSET_REGISTRY.md) 和机器可读账本 `EXPERIMENT_LEDGER.jsonl` 中，未隐藏。

## 口径

`d9f83ac` 运行中，`51c41d0` 之前的 adapter 虽然接受并记录了 `POST_GOAL_STEPS=200`，但没有把该参数传给 rollout body。因此这些运行全部标为 `pre_correction`：保留真实 stage/goal 分子分母，但不能算作当前严格 200-step 结果。修复说明见 [POST_GOAL_200_CORRECTION_20260725.md](../evaluation_campaigns/latest_openhelix_d9f83ac_exact20_20260725/POST_GOAL_200_CORRECTION_20260725.md)。

`excluded` 表示有实际 episode，但 generic materializer 没有加载原始 runtime evaluator hash；`partial` 表示已有真实官方分子/分母，但尚未跑满目标；`invalid` 表示没有可计入的官方 episode。

## 本 Git 窗口实际运行

| Task | 运行/输出的实际有效 episode | stage 成功 | 结论 |
| ---: | --- | ---: | --- |
| 1 | 20 | 14 | 原版 `66e7894` 冻结拓扑，14/20；历史 pinned，不是当前 d9 strict。 |
| 2 | 15 | 15 | generic snapshot 的 15/15 是真实日志，但加载错误 driver，`excluded`；corrected restart 写出 0 条 official score。 |
| 3 | 14 | 11 | generic snapshot 的 11/14 真实但 driver 错，`excluded`；corrected restart 0 条 official score。 |
| 6 | 20 | 17 | d9 两卡，17/20；`pre_correction`。 |
| 7 | 20 | 4 | d9 单卡 direct20，4/20 stage、10/20 goal；`pre_correction`。另有原始拓扑 4/8 stage、6/8 goal。 |
| 10 | 10 | 0 | controller-assisted 诊断，0/10 full stage。另有 direct20：2/20 stage、7/20 goal，`pre_correction`。 |
| 12 | 20 | 10 | d9：10/20，`pre_correction`；corrected original-runtime restart 已完成 9 条，其中 6 条 stage/goal 成功。 |
| 13 | 20 | 14 | d9：14/20，`pre_correction`；corrected original-runtime restart 已完成 9 条，其中 5 条成功。 |
| 14 | 0 | 0 | 首个 20ep job 在 callback 参数边界失败，`invalid`。compat smoke 有 1 条官方 episode 但 stage=0；compat exact restart 有 3 条 official score，stage=0。 |
| 16 | 29 | 26 | controller-assisted 原始诊断 26/29 full stage；另有 1/1 d9 smoke 与两卡冻结 17/20 stage、18/20 goal，均 `pre_correction`。 |
| 18 | 10 | 6 | generic 6/10 因 driver 与 lift gate 错误而 `excluded`；corrected original-runtime restart 已完成 6 条，其中 5 条成功。 |
| 20 | 13 | 7 | 固定 seed106 的 d9 worker batch，真实 summary 为 7/13，`pre_correction`；其余 7 条没有写出 valid official summary。 |
| 21 | 0 | 0 | 请求 20 条，但 20 条都是 `invalid_episode`，无有效官方 episode。 |
| 25 | 8 | 2 | corrected original-runtime restart 已完成 8 条，2 条成功，未满 20。 |
| 26 | 20 | 5 | d9 direct20：5/20，`pre_correction`；corrected original-runtime restart 没有写出 official score。 |

## 本窗口没有可审计 rollout 的任务

Task 4、5、8、9、11、15、17、19、22、23、24 在本仓库这一 Git 时间窗口内没有找到可计入的新官方 summary。此前的历史视频/成功包仍在其它目录，但不在这里冒充为“昨晚到现在的复跑”。

## 关键外部证据根

- Task1：`/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_repro20_historical/task1_historical66e789_exact20_20260725_084435/task1/official_task_summary.tsv`
- Task2/3 generic 与 corrected 比较：[HISTORICAL_DIRECT_COMPARISON_20260725.md](../evaluation_campaigns/all18_repo_direct_exact20_20260725/runs/HISTORICAL_DIRECT_COMPARISON_20260725.md)
- Task6：`/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/counting_historical_two_gpu/task6_historical_d9f83ac_exact20_20260725_090223/aggregate/aggregate.json`
- Task12/13 d9：`/data/user/xiangqim/hlei573_borrow_outputs/latest_openhelix_d9f83ac_exact20_20260725/`
- Task16：`/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/counting_historical_two_gpu/task16_historical_d9f83ac_exact20_20260725_114200_d9frozen/summary.tsv`
- Task20：`/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/microwave_d9_two_gpu/task20_v110_d9_seed106_repeat20_20260725_120537`
- Task21：`/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task21/task21_all18_d9_direct20_single_gpu_20260725_070600/aggregate/summary.tsv`
- Task26：`/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task26/task26_all18_direct20_seed104_20260725_055516/logs_task_sync_hold/task26_all18_direct20_seed104_20260725_055516/official_task_summary.tsv`

## 严格结果门槛

从 `51c41d0` 起，只有 manifest 明确为 `post_goal_steps=200`，并且日志同时出现 `[POST_GOAL_STAGE_REACHED]` 和恰好 200 step 后的 `[POST_GOAL_STAGE_EXIT]` 的 run，才能记为 `current_strict`。截至本审计，没有一条本窗口新 run 满足这三个条件；不能把上表中的 pre-correction 数字说成当前严格结果。
