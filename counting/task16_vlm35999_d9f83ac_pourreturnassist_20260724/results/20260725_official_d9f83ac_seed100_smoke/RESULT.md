# Task16 Latest-Official Seed100 Smoke

## Result

- Date: 2026-07-25
- Run ID: `task16_official_d9f83ac_vla35999_seed100_smoke_20260725_005450`
- Slurm job: `436546` on `ACD1-20`, submitted as `zzhang510`
- Official source: `OpenHelix-Team/RoboMemArena`
- Official commit: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- Official stage score: `100.0%`
- Stage success: `1/1`
- Reported goal success: `1/1`
- Duration: `420.95 s`

## Frozen Inputs And Controls

- VLA: original fullvlm-v2 noflip `35999` with norm SHA256
  `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.
- VLM: Task16 balanced pick/post-lift `checkpoint-100`.
- Environment seed and VLA policy seed: `100`.
- `replan_steps=1`, `vlm_interval=25`, and `max_steps=2500`.
- `oracle_prompt_injection=off` and `stage_prompt_override=off`.
- The VLM itself emitted `pick milk`, `pour milk into red coffee mug 1st`,
  and `pour milk into red coffee mug 2nd` during rollout.
- The only controller assist is Task16's rotation-only pour return: after a
  VLM-selected pour reaches the official target radius and tilt threshold, it
  reverses action channels `3:6` while preserving the VLA translation and
  gripper actions. It does not inject prompts, reset the environment, or move
  objects.

## Integrity

The copied `run_manifest.txt` pins the following implementation hashes:

- Official scorer: `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`
- Official evaluator: `b19cb0afa7fe1c9044495d7aeb57dccc754cdca60fe075eadfe8d667f1974fb9`
- Task16 evaluator entrypoint: `c38e7335012e29633d3d8e8096852a534d610ac2dc201539f26708a32a0388d0`
- Self-contained policy server: `91b22fc948bcd9d7175ed709a07d31ab1f542a96f3e22af85fbb3bf90e27c9cf`

`summary.tsv`, `summary.json`, `prompt_trace.tsv`, `run_manifest.txt`,
`run_result.txt`, `evidence/sync_vlm.log`, `evidence/sync_vlm_trace.jsonl`,
`evidence/pour_tilt_trace.csv`, both success videos, and `SHA256SUMS.txt` are
copied from the completed run. The model checkpoints and raw environment data
remain outside Git at:

`/data/user/zzhang510/hlei573_borrow_outputs/task16_official_d9f83ac_smoke_20260725_005450`

The committed main video is:

`videos/task16_success_ep0_seed100.mp4`
