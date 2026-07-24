# Task18 original snapshot single-GPU probe

This version tests whether the same historical Task18 rollout can run with the
VLA policy server and VLM planner co-located on one 80 GiB GPU.

## Identical semantic inputs

- historical evaluator and launcher SHA256 checks
- Task18, seed 104, max steps 2200, replan steps 5
- VLA policy, VLM checkpoint, checkpoint norm asset, target JSON and passage
  JSON listed in [LOCAL_RUNTIME_MANIFEST.md](LOCAL_RUNTIME_MANIFEST.md)
- modern campaign adapter disabled

## Deliberate differences from v2

```text
Slurm GPU allocation: 1 rather than 2
VLA_CUDA_VISIBLE_DEVICES=0
VLM_CUDA_VISIBLE_DEVICES=0
NUM_TRIALS=1 for the first capacity/behavior probe
```

The launcher fails before rollout if VLA and VLM do not share the same visible
GPU. A successful v3 probe demonstrates single-card feasibility only; it is
not a claim that the historical dual-GPU runtime was reproduced unchanged.
