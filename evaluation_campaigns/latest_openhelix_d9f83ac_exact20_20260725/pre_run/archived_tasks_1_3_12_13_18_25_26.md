# Archived Task Exact20 Pre-Run Record

## Scope

Tasks `1, 3, 12, 13, 18, 25, 26` will each run exactly twenty episodes.
Task 2 is intentionally excluded.

## Frozen rollout contract

- VLA: original fullvlm-v2 noflip `35999`.
- Norm SHA256: `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.
- The historical hold, passage, VLM prompt and rollout flags are retained.
- The official source root is only `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Required stage scorer SHA256: `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.
- The runtime preflight fails if `task2_26_reference_stage.py` is missing or differs. No old-score fallback is allowed.

## Submission contract

`run_archived_exact20_inside_allocation.sh` accepts only a task id and an ignored local runtime environment file. The environment file supplies the VLM path and carries no user-visible checkpoint location into Git. Each run copies the active launcher, local frozen wrapper, official scorer and BDDL to its external output directory.
