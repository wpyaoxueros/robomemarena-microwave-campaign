# Task24 v131 Frozen Retry

- Scope: one Task24 episode, `seed=108`, using the original v131 code snapshot.
- Runtime source: the frozen v131 pack dated 2026-07-18.
- Permitted materialization changes: required private environment variables replace historical hard-coded paths; HDF anchor paths expand from `ROBOMEMARENA_FULLVLM_DATA_ROOT`; the historical hard-coded relative launcher is redirected to this copied runtime.
- These changes do not alter any supplied rollout parameter, model, scorer, hold/release rule, anchor frame, task seed, or prompt policy.
- VLM prompts remain autonomous. All `ORACLE_*` flags remain zero.
- Scorer must be RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03` and must contain `task2_26_reference_stage.py`.
- The VLA norm repo is materialized under the historical asset identifier
  `robomemarena_fullvlm_v2_noflip_dataset_v2`; its norm file SHA-256 is
  `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.
  This reproduces v131's local-norm load followed by the data-config fallback
  route, rather than the distinct fallback-asset route seen in the aborted
  pre-rollout launch.
- This retry does not claim trajectory identity with the historical success because v131 did not record the VLA diffusion sampling RNG/noise stream.
