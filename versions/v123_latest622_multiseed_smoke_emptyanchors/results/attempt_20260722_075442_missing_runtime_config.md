# Attempt 20260722 075442: Missing Runtime-Config Failure

## Scope

- Version: `v123_latest622_multiseed_smoke_emptyanchors`
- Seeds: 104 and 107
- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`
- Execution commit: `bb72e75cde9b47098a5989ba3e95a2454c6e08f2`

## Outcome

The valid empty-anchor object was materialized correctly as `{"tasks": {}}`.
Both processes then failed before the first environment step because a nested
historical runner overwrote the v121 min-hold configuration with a path that
is not part of the frozen package. No video was rendered and these are invalid
startup attempts, not evaluation episodes.

| Seed | Status | Error |
| --- | --- | --- |
| 104 | invalid startup failure | missing `task21_eef_runtime_pickplace_hold30_20260718.json` |
| 107 | invalid startup failure | missing `task21_eef_runtime_pickplace_hold30_20260718.json` |

## Successor

v124 changes only the nested export from unconditional assignment to a default
assignment. The already-frozen v121 caller value
`task21_v121_min_hold_steps.json` is therefore preserved. No hold values,
VLM/VLA inputs, prompt policy, scorer, or anchor policy are changed.
