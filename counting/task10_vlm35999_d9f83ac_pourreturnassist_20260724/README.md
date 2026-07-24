# Task10 Counting Reproduction Snapshot

This frozen Task10 snapshot is kept in the shared microwave campaign repository
so that the exact code, result table, logs, and videos remain under Git. It is
a counting task, not a microwave result.

## Frozen Contract

- Source counting repository and code commit:
  `https://github.com/wpyaoxueros/robomemarena-counting-vlm35999-latest-repro.git`
  at `555f96411d231aab380b82cff8af22419e3b9a4c`.
- Remote RoboMemArena scorer:
  `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- VLA: original fullvlm-v2 checkpoint `35999`, with the required self-contained
  norm asset `assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`
  SHA256 `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.
- VLM: `task10_pickpour1_pour2_boundary_vlm_20260724_052511/checkpoint-750`.
  The checkpoint binary is not included; its original absolute reference is
  preserved in `evidence/run_manifest.txt`.
- Prompt source: VLM only. All oracle prompt flags are zero.
- Guard: `PROMPT_NO_REGRESSION=1` only blocks backward execution; it does not
  generate a forward prompt.
- Controller: after a VLM-selected wine-pour prompt, bottle-to-mug proximity,
  and a measured tilt departure, it reverses only rotation channels `3:6` to
  return upright. VLA translation and gripper actions are preserved.

This is therefore **VLM-prompted controller-assisted**, not an oracle result.

## Recorded 10-Episode Result

The recorded run used seeds `100--109`, VLA policy seed `100`, `REPLAN_STEPS=1`,
and VLM polling interval `25`. It completed all ten episodes:

- Full stage success: `0/10`.
- Lift + first pour completed: `3/10` (seeds `100`, `106`, `108`).
- Second pour completed: `0/10`.
- Mean remote stage score: `26.7%`.

This is a diagnostic archive, not a successful Task10 claim. In each two-stage
episode, after physical `Pour_One` the VLM returned to `pick wine bottle` or
`pour wine into mug 1st`; it never generated `pour wine into mug 2nd`.
`results.tsv`, `evidence/logs.tar.gz` (the original ten logs), and all
main/wrist videos are included. `evidence/SHA256SUMS.txt` verifies every
included evidence file.

## Reproduction

Use a two-GPU Slurm allocation and supply local paths explicitly:

```bash
export SOURCE_ROOT=/path/to/RoboMemArena_d9f83ac
export OPENPI_ROOT=/path/to/openpi
export OPENPI_INFERENCE_ROOT=/path/to/openpi_inference
export VLA_CKPT=/path/to/original_fullvlmv2_35999
export VLM_CKPT=/path/to/task10_checkpoint_750
./run_task10_10ep.sh
```

The runner verifies the expected norm inside `VLA_CKPT` and fails if the frozen
remote scorer files are absent. Check out `SOURCE_ROOT` at the commit listed
above before running. Set `NUM_TRIALS=1` for a smoke run.

No model weights or raw VLM input-frame dumps are committed here. The included
video/log evidence is sufficient to audit the recorded 10-episode diagnosis.
