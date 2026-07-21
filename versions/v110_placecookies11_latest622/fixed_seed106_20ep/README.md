# Fixed seed106 20ep harness

这套脚本把同一个模拟器 seed `106` 独立执行 20 次，用来区分 seed 难度与
Pi0 diffusion/闭环物理随机性。每个有效 episode 都必须满足：

- `summary.tsv` 只有一条完整记录；
- 存在完整主视角 mp4；
- 所有 `ORACLE_*` 为 `0`；
- `place cookies` 阈值为 `0.11 m`；
- Norm SHA256 与版本记录一致；
- 代码快照和官方 scorer commit 校验通过。

建议分成 5 个 GPU worker，每个 worker 跑 4 次：

```bash
export BATCH_ROOT=/path/to/batch
for worker in 0 1 2 3 4; do
  WORKER_ID=${worker} REPEATS=4 \
    bash versions/v110_placecookies11_latest622/fixed_seed106_20ep/scripts/run_worker.sh
done
```

五个 worker 都生成 `COMPLETE` 后聚合：

```bash
python versions/v110_placecookies11_latest622/fixed_seed106_20ep/scripts/aggregate_results.py \
  "${BATCH_ROOT}"
```

GPU/Slurm 分配由调用方负责；不要在五个 worker 之间复用同一 GPU。
