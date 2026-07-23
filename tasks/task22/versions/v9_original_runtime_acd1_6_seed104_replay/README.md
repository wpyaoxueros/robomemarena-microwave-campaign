# Task22 v9: Original Runtime on Historical Node

v9 is a single-variable follow-up to v8.

- Parent runtime: `../v8_legacy_original_runtime_seed104_replay`.
- It reuses the fully frozen original legacy runtime, VLM inputs, VLA inputs,
  norm repository, task, seed, and rollout settings from v8 without change.
- The only intended difference is a node constraint: `ACD1-6`, which the
  historical successful policy-server log recorded.
- The watcher performs fresh 1-GPU and 2-GPU probes in one `zzhang510` shell
  before the formal replay, trying `acd_u`, `acd_ue`, then `emergency_acd`.
- No oracle prompt injection is permitted. A result is recorded only after a
  full summary and MP4 are present.

This remains a legacy-scorer reproduction, not a current remote-scorer result.
