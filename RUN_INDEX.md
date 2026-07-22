# Run Index

This index records the immutable pre-run state for each active lane. Raw videos
and debug artifacts are stored in the shared `irpn` artifact root and are not
committed here.

| Task | Version | Git repository | Frozen pre-run commit | Planned seeds | Status |
| --- | --- | --- | --- | --- | --- |
| 20 | v110_placecookies11_latest622 | `robomemarena-task20-v49c6-repro` | `bcd6fbb` | 106 x 20 | completed, result pushed separately |
| 21 | v122_latest622_multiseed_smoke | `robomemarena-task21-v121-repro` | `768675d` | 104, 107 | invalid startup recorded: empty JSON list violates anchor contract |
| 21 | v123_latest622_multiseed_smoke_emptyanchors | `robomemarena-task21-v121-repro` | `80e0496` | 104, 107 | invalid startup recorded: a nested script overwrote min-hold config with missing legacy file |
| 21 | v124_latest622_multiseed_smoke_preserve_minhold | `robomemarena-task21-v121-repro` | `80e0496` | 104, 107 | seed107 valid success: 3/3 stages; seed104 valid 2/3-stage failure |
| 21 | v125_pickchocolate_tol050_seed104_smoke | `robomemarena-task21-v121-repro` | `8bb9390` | 104 | incomplete diagnostic: VLM reached `place butter`, but pick-forward direction guard blocked handoff at 1.14cm; does not assess the changed pick-chocolate tolerance |
| 22 | v1_latest622_baseline_smoke | `robomemarena-task22-autonomous-repro` | `aede542` | 104, 105 | seed104 valid 1/3 stage; seed105 invalid process abort, excluded |
| 23 | v156_fixedseed105_repeat20_replay | `robomemarena-task23-v155-fixedseed105-repeat20` | `a1f54ae` | 105 x 20 | incomplete: 4 valid episodes (1 stage-only success); 8 rc=134 evaluator aborts excluded; remaining workers cancelled |
| 23 | v157_acd1_1_serial20_replay | `robomemarena-task23-v155-fixedseed105-repeat20` | `9da6466` | 105 x 20 | pre-run pushed: same v155 rollout, scheduling-only ACD1-1 serial replay with fail-fast nonzero exit |
| 24 | v123_latest622_seed107_108_smoke | `robomemarena-task24-v123-autonomous-repro` | `7235d5e` | 107, 108 | seed107 valid 1/3 stage; seed108 invalid process abort, excluded |

All listed runs require remote scorer commit `62214036103ee8d5fef9b475dd8b344b6e2cfc03`, VLM-generated prompts, no `ORACLE_*` prompt injection, and stage-only scoring with `Close_Microwave` optional.
