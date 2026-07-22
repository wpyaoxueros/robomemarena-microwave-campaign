# Task22 v3 Processor Compatibility Probe

- Status: PASS.
- Code commits used: `f8b80e6` and `62a7c1d`.
- The unmodified historical checkpoint failed in the current training
  environment before model loading because `extra_special_tokens` was a JSON
  list and the installed Transformers version calls `.keys()` on that field.
- The private overlay preserved all 13 listed multimodal tokens in
  `tokenizer.json`, changed only the overlay configuration field to an empty
  mapping, and left the source checkpoint untouched.
- A fresh one-GPU Slurm allocation loaded the overlay as `Qwen3VLProcessor`.
  The checked token IDs for vision start/end/pad and image/video pad were all
  valid, so the compatibility gate passed.

The next run must use this overlay through `COMPAT_MODEL_DIR`; it must not
edit the historical checkpoint in place.
