# Official RoboMemArena Exact20 Run

- Official repository: `OpenHelix-Team/RoboMemArena`
- Official scorer commit: `66e7894f8188be8114911e5df0f8bf89fe4581ce`
- Submit user: `zzhang510`
- Slurm account flag: none
- Episodes: 20 per task, seeds 104-123
- Tasks: 1, 2, 3, 12, 13, 18, 25, 26
- GPU allocation: 2 GPUs per task, 16 GPUs total
- Output root: `/data/user/zzhang510/hlei573_borrow_outputs/repro20_official66e789_20260704_1815`

## Jobs

| Task | Job |
|---|---:|
| 1 | 390717 |
| 2 | 390731 |
| 3 | 390719 |
| 12 | 390720 |
| 13 | 390721 |
| 18 | 390722 |
| 26 | 390723 |
| 25 | 390724 |

Official outputs are `official_episodes.tsv`, `official_task_summary.tsv`, and `official_summary.json` inside each completed run.

Task2 job `390718` was canceled after one invalid episode exposed that the historical Task2 BDDL filename contained the wrong cream/pudding goal. Task2 restarted as job `390731` using the frozen official remote BDDL; the invalid episode is excluded. Its output root is `/data/user/zzhang510/hlei573_borrow_outputs/repro20_official66e789_task2bddlfix_20260704_1827`.
