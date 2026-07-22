# Task24 v131 Frozen Retry

- Scope: one Task24 episode, `seed=108`, using the original v131 code snapshot.
- Runtime source: the frozen v131 pack dated 2026-07-18.
- Permitted materialization changes: required private environment variables replace historical hard-coded paths; HDF anchor paths expand from `ROBOMEMARENA_FULLVLM_DATA_ROOT`; the historical hard-coded relative launcher is redirected to this copied runtime.
- These changes do not alter any supplied rollout parameter, model, scorer, hold/release rule, anchor frame, task seed, or prompt policy.
- VLM prompts remain autonomous. All `ORACLE_*` flags remain zero.
- Scorer must be RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03` and must contain `task2_26_reference_stage.py`.
- This retry does not claim trajectory identity with the historical success because v131 did not record the VLA diffusion sampling RNG/noise stream.
