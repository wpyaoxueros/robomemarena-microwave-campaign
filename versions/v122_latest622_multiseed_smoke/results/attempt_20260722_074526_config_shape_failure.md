# Attempt 20260722 074526: Configuration-Shape Failure

## Scope

- Version: `v122_latest622_multiseed_smoke`
- Seeds: 104 and 107
- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`
- Execution commit: `200bc49d999f8e96f3658cb481c0df30373891c6`

## Outcome

Both processes loaded the VLM and then failed before the first environment
step. No video was rendered and neither result is a valid evaluation episode.

| Seed | Status | Error |
| --- | --- | --- |
| 104 | invalid startup failure | `AttributeError: 'list' object has no attribute 'get'` |
| 107 | invalid startup failure | `AttributeError: 'list' object has no attribute 'get'` |

## Root Cause

The v122 release-anchor template was the empty JSON list `[]`. The evaluator
contract requires either a top-level object or an object containing a `tasks`
object. The failure happened while parsing the empty template, before rollout.

The successor version will preserve the intended zero-anchor behavior using the
valid empty form `{"tasks": {}}`. It will not change the VLM, VLA, prompt
policy, hold/release policy, scorer pin, or seed selection.
