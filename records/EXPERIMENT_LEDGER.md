# 2026-07-24 晚至今实验总账索引

本总账只收录本仓库从 `2026-07-24 18:00 +08:00` 至今实际执行的运行，不把更早历史成功包的结果重新计入。逐条完整路径、VLA、VLM、norm、scorer、入口与输出根在 [EXPERIMENT_LEDGER.jsonl](EXPERIMENT_LEDGER.jsonl)；人工审计在 [RECENT_EVALUATION_AUDIT_20260725.md](RECENT_EVALUATION_AUDIT_20260725.md)。

| 类别 | 实际结果 | 是否可算当前严格结果 |
| --- | --- | --- |
| 原版冻结评分有效结果 | Task1 14/20；Task12 corrected 6/9；Task13 corrected 5/9；Task18 corrected 5/6；Task25 corrected 2/8 | 否，原评分器历史 pinned 且部分未满 20。 |
| d9 pre-correction 行为证据 | Task6 17/20；Task7 4/20；Task10 2/20；Task12 10/20；Task13 14/20；Task16 17/20；Task20 7/13；Task26 5/20 | 否，`51c41d0` 前没有实际执行 post-goal 200。 |
| 代码/拓扑无效 | Task2/3/18 generic driver 错；Task14 callback 错；Task21 20 个 invalid episode；Task2/3/26 corrected restart 无 official score | 否。 |
| 诊断 | Task10 0/10、Task16 controller-assist 26/29、Task16 smoke 1/1 | 诊断用途，不与纯严格 20ep 混算。 |

目前没有 `current_strict` 行。新实验必须在同一个 Git commit 中更新 JSONL、此索引和原始 result/manifest 路径，随后运行：

```bash
python3 scripts/validate_experiment_ledger.py
```

不要从外层空 `summary.tsv` 推断 0/20；要先读取 `official_task_summary.tsv`，或逐条扫描 `ep*/sync_vlm.log` 的 `[OFFICIAL_SCORE]`。
