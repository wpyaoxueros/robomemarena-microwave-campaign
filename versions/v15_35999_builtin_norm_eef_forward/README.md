# Task22 v15: Original 35999 With Built-In Norm and VLM-Owned EEF Gates

This version keeps the original `35999` VLA and the same Task22 VLM as v14.
It changes no model weights and does not generate any task prompt.

## Fixed Contract

- Remote Task22 scorer commit: `8b7710924f862ab1c8dea69adada62e8c462de40`.
- The VLA norm repository is derived from the original checkpoint's own
  `assets/robomemarena_fullvlm_v2_noflip_dataset_v2` directory. This is the
  asset ID expected by the checkpoint, so the server must not use an asset
  fallback.
- VLM owns every prompt. All `ORACLE_*` controls are `0`; completed-subtask
  prompt injection, stage locks, object anchors, object-region gates, lift
  gates, and gripper gates are disabled.
- The evaluator may hold the *current VLM prompt* until its EEF target reaches
  two consecutive samples within `0.08 m`. It never substitutes a next prompt.
- A held prompt can release only when the VLM itself emits the immediately
  following primitive. The two preserved release anchors reset robot joints
  and gripper only; no object state is moved.
- Required Task22 stages are lift, pour one, pour two, tomato aside, open
  microwave, and cookies in microwave. Closing the microwave is audit-only.

## Why This Is a Separate Version

v14 established that the original 35999 policy can lift tomato sauce, but a
sync VLM update replaced `pick tomato` between the first and second EEF
near-target samples. v15 tests the smallest timing-only correction: preserve
that VLM-selected prompt until the EEF hold is actually observed, then wait for
a VLM-selected legal next prompt.

Runtime outputs are ignored by Git, but every rollout snapshots the evaluator,
scorer, BDDL, configuration, logs, videos, and checksums.
