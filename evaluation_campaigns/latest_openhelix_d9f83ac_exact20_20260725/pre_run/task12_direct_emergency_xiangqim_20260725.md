# Task12 Direct Formal Submission From `xiangqim`

## Intent

Run Task12 for exactly 20 episodes using the frozen archived task path and
current remote scoring source.

## Frozen contract

- Original fullvlm-v2 noflip VLA `35999` and its original matching norm.
- The archived Task12 VLM checkpoint is supplied through a private runtime
  environment, so no checkpoint path is published in Git.
- Historical Task12 rollout, hold, passage and VLM-prompt behavior remain
  unchanged.
- Official source is `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Required `task2_26_reference_stage.py` SHA256 is
  `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.
- The preflight fails instead of using an old scorer fallback.

## Resource contract

- Submit account: `xiangqim`, no explicit `-A`.
- Partition: `emergency_acd`.
- Shape: 2 GPUs, 16 CPUs, 480 GB, 12 hours.
- Output root: account-owned, `irpn` setgid; the result bundle retains all code
  snapshots, summary files, logs and videos.
