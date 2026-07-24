# Task12 one-GPU colocation preflight result

## Scope

- Submit account: `xiangqim`
- Slurm job: `436804`
- Remote scorer: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- Models: archived Task12 VLM and original VLA `35999`
- GPU arrangement: one allocated H100 80 GB GPU, with the VLA server and VLM
  evaluator both bound to the same Slurm GPU.

## Observed evidence

1. The VLA server restored its checkpoint, loaded the checked norm, and opened
   its websocket port.
2. The VLM loaded on the same GPU without OOM.
3. The rollout emitted autonomous VLM prompts and received VLA action chunks:
   it completed `Open Middle Drawer`, released to `pick cookies`, and later
   reached the pick hold after the cookies lift gate.
4. Model residency was approximately 61.4 GiB for VLA plus 18.7 GiB for VLM,
   leaving about 1.4 GiB on an 80 GB H100.

## Interpretation

Single-GPU VLM+VLA execution is viable for this architecture, but it has a
small memory margin. The batch was deliberately stopped before its one episode
finished so its three GPUs could be converted to three independent formal
one-GPU exact-20 workers. This preflight is evidence of compatibility only and
is excluded from all reported success rates.
