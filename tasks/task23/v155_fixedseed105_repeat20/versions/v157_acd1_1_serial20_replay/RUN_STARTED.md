# Task23 v157 Launch Record

- Pre-run source commit: `9da6466`.
- Fresh same-shell 1-GPU Slurm probe: job `428590`, completed on `ACD1-1`.
- Serial replay job: `428591`, submitted by `zzhang510` through tmux+srun.
- Allocation: `ACD1-1`, 2 GPUs, 8 CPUs, currently available node memory
  requested dynamically as `1385600M`.
- Output artifact directory:
  `microwave_campaign_20260722/outputs/task23_v157_acd1_1_serial20_20260722_083500`.
- Contract: 20 separate `NUM_TRIALS=1`, `SEED=105` calls; a nonzero evaluator
  return code terminates the job rather than silently counting an invalid run.
