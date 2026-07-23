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
