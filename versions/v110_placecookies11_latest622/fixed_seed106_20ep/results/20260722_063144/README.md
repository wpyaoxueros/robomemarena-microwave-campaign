# Fixed Seed106 20-Episode Result

This is the frozen v110 Task20 reproduction run created on 2026-07-22.

- Episodes: `20`, all with fixed environment seed `106`.
- Official scorer commit: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Success rule: stage-only; `Close_Microwave` is optional.
- Result: `8/20` stage successes (`40.0%`), average stage score `71.67%`.
- Prompt policy: VLM-generated prompts; all oracle prompt-injection flags are disabled.
- Runtime policy: EEF hold/release and robot-only release anchors only; no object-moving anchor.

`episodes.tsv` contains one sanitized row per episode. `frozen_snapshot_sha256.tsv`
records the exact code snapshot used by the batch. The raw videos, debug frames, and
unredacted logs are archived under the matching Task20 artifact key in the shared
`irpn` experiment storage; they are intentionally not committed to GitHub.

The VLA checkpoint is represented only by its public experiment identifier in the
parent v110 manifest; no local model path or model weights are included here.
