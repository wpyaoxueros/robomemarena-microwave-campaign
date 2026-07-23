# Task22 V5 Native Boundary Train With GPU Gate

V5 is the V3 c4 native pour-boundary training contract plus one infrastructure
gate. It uses the same dataset, private compatibility overlay, optimizer,
batch-selection order, frozen vision tower, predictive-coding head, and training
steps as V3.

Before every one-step batch probe and before the formal train, V5 invokes the
committed V4 preflight. The gate records CUDA visibility and rank-to-GPU UUID
binding and rejects an allocation with an existing compute process. It neither
loads an evaluator nor changes VLM prompts, data labels, or policy behavior.

The V3 attempt on `ACD1-1` is invalid infrastructure evidence only; this V5
entry is the reproducible retry path.
