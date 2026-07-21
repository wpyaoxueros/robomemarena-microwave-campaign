# Run Index

This index records the immutable pre-run state for each active lane. Raw videos
and debug artifacts are stored in the shared `irpn` artifact root and are not
committed here.

| Task | Version | Git repository | Frozen pre-run commit | Planned seeds | Status |
| --- | --- | --- | --- | --- | --- |
| 20 | v110_placecookies11_latest622 | `robomemarena-task20-v49c6-repro` | `bcd6fbb` | 106 x 20 | completed, result pushed separately |
| 21 | v122_latest622_multiseed_smoke | `robomemarena-task21-v121-repro` | `200bc49` | 104, 107 | queued for autonomous reproduction |
| 22 | v1_latest622_baseline_smoke | `robomemarena-task22-autonomous-repro` | `aede542` | 104, 105 | queued for autonomous baseline |
| 23 | v156_fixedseed105_repeat20_replay | `robomemarena-task23-v155-fixedseed105-repeat20` | `a1f54ae` | 105 x 20 | running, five workers x four episodes |
| 24 | v123_latest622_seed107_108_smoke | `robomemarena-task24-v123-autonomous-repro` | `7235d5e` | 107, 108 | queued for autonomous reproduction |

All listed runs require remote scorer commit `62214036103ee8d5fef9b475dd8b344b6e2cfc03`, VLM-generated prompts, no `ORACLE_*` prompt injection, and stage-only scoring with `Close_Microwave` optional.
