# Task23 v145 Root-Cause Test

- Baseline: `task23_v144_c400_autonomous_after_v49_20260721`, seed 104, Task23, official scorer commit `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Observed failure: after the VLM selected `place cream`, release from `pick cream` applied robot-only anchor `place_cream_2_seed104_task23.hdf5:f40`; the rollout then missed the place-cream target by `0.16270m` and regressed before reaching `pick popcorn`.
- Hypothesis: that f40 robot reset, not the VLM prompt selection or official scorer, causes the first placement failure.
- Single change: remove only `pick cream -> place cream` f40 from the release-anchor JSON. Keep VLM checkpoint, original VLA 35999, seed, scorer, hold timing, completed context, all prompt guards, and remaining robot-only anchors unchanged.
- Expected evidence: the rollout reaches or improves `02_Place_Cream_Microwave`; if it does not, return to diagnosis instead of stacking another fix.
- Autonomy classification: VLM prompts, no oracle prompt injection, no object anchor. This run may use robot-only state anchors after a VLM-authored next prompt and an EEF hold/release.
