# Frozen Provenance

- Runtime source family: original-35999 microwave sync-hold evaluator.
- Official scorer commit: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Required scorer file: `evaluation_benchmark/scripts/task2_26_reference_stage.py`.
- Public package policy: model and dataset locations are injected only through
  a local, ignored environment file.
- Autonomy policy: VLM supplies prompts; timing helpers may hold or release
  actions but cannot write the next prompt or move an object body.
