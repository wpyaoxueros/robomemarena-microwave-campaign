# Task22 v22 Results

## Seed-State Smoke

- Date: 2026-07-23
- Submitter: `zzhang510`
- Slurm job: `433201` on `ACD1-13`, `COMPLETED`, exit `0:0`
- Remote scorer commit: `8b7710924f862ab1c8dea69adada62e8c462de40`
- Seed: `104`
- Result: same-environment reset physical state `true`; same-environment
  observation state `true`; fresh-environment physical state `true`; fresh
  environment observation state `true`.
- Evidence: [seed_state_smoke_20260723_223227.json](evidence/seed_state_smoke_20260723_223227.json)
  (`sha256=9ac02f94329e56ebbd922deb26bb8a4624f6f33f31cbc199e5526535cf419c06`).

This rules out seed-104 initial-state drift across reset or a newly constructed
environment as the explanation for the v20/v21 trajectory difference. It does
not test policy or VLM determinism.

## VLM-150 Rollout

- Date: 2026-07-23
- Submitter: `zzhang510`
- Slurm job: `433218` on `ACD1-1`, `COMPLETED`, exit `0:0`
- Remote scorer commit: `8b7710924f862ab1c8dea69adada62e8c462de40`
- Seed: `104`; maximum environment steps: `3000`; VLA replan: `10`.
- Result: `1/6` required stages, `stage_success=false`, `goal_success=false`.
  Only `01_Lift_Tomato_Sauce` completed; the first pour did not meet the
  remote stage condition.
- Evidence: [v22_seed104_summary.tsv](evidence/v22_seed104_summary.tsv)
  (`sha256=216d0e0dbf794211686f3912f8d9347cd8e43e718973e04089f04238b86a70c7`) and
  [v22_seed104_run_manifest.json](evidence/v22_seed104_run_manifest.json)
  (`sha256=bc26f91d70308f7aa75b48f83385456ff819c65954f8bcd9db94a5a29c377021`).
- Local full-rollout log SHA-256:
  `f398631d2606bb0e20e00b61d6253adfdd3989013092675359ce2c720ad80a69`.
- Local main-video SHA-256:
  `db0e5d751221c983da7590f1ecb99bfe12bcc1202befcbbaf26aca9d51d61c08`.

This falsifies the v21 abort workaround hypothesis for this run: lowering raw
VLM sampling to 150 did prevent an abort, but it did not preserve the v20
five-stage physical trajectory. The next comparison must isolate the remaining
execution-path difference rather than change more settings together.
