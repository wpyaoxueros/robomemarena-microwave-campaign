# Task16 Counting Reproduction Snapshot

This frozen counting snapshot is stored in the shared microwave campaign
repository for one Git-managed reproduction history. It is a counting task,
not a microwave result.

## Frozen Contract

- Source counting repository:
  `https://github.com/wpyaoxueros/robomemarena-counting-vlm35999-latest-repro.git`
- Source package commit: `e61dbf5e8c938810084df62d3bdb9608433dce71`.
- Remote RoboMemArena scorer: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- VLA: original fullvlm-v2 `35999`, matched norm SHA256
  `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.
- VLM: Task16 balanced pick/post-lift checkpoint 100. The checkpoint binary is
  not included; supply it with `VLM_CKPT`.
- Controller: only after a VLM-selected milk-pour prompt, official target-radius
  contact, and a `0.15 rad` tilt departure, reverse only action channels `3:6`
  until the milk returns upright. It preserves VLA translation and gripper.
- Autonomy: all oracle prompt flags are off. `PROMPT_NO_REGRESSION=1` prevents
  backward prompt changes but does not generate a next prompt.

## Recorded Result

The initial valid seed-100 run is `1/1`: stage `100%`, goal `100%`, and no
extra pour. It is correctly classified as **VLM-prompted controller-assisted**,
not pure VLA execution. The raw video and full machine-local logs remain in the
source repository commit above; this shared repository intentionally stores
only executable code and portable result metadata.

## Reproduction

Set these paths to local assets, then run the entrypoint inside a valid 2-GPU
Slurm allocation:

```bash
export SOURCE_ROOT=/path/to/RoboMemArena_d9f83ac
export OPENPI_ROOT=/path/to/openpi
export OPENPI_INFERENCE_ROOT=/path/to/openpi_inference
export VLA_CKPT=/path/to/original_fullvlmv2_35999
export VLM_CKPT=/path/to/task16_checkpoint_100
./run_task16_29ep.sh
```

The default is 29 episodes with environment seeds `100--128` and policy seed
`100`. Override `NUM_TRIALS` only when running a smaller smoke test.
