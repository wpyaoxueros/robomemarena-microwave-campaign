# Frozen provenance

## Scope

Task20: cookies and chocolate microwave. This package is a code-only extraction of the v49c6 autonomous runtime.

## Frozen evaluator

- RoboMemArena commit: `514ecdf86ba47d496ab1728a827670833107ffd3`.
- Required files: `evaluation_benchmark/scripts/eval_common.py`, `task2_26_reference_stage.py`, Task20 BDDL, and the Task2-26 VLM/VLA reference evaluator.
- The run refuses to start if the checkout commit differs or `task2_26_reference_stage.py` is missing.

## Runtime contract

- seed `104`, one episode, `MAX_STEPS=1000`, `REPLAN_STEPS=10`.
- All `ORACLE_*` flags are zero.
- `VLM_COMPLETED_SUBTASKS_MODE=off`; completed-stage updates do not write prompts.
- EEF-only holds: no object anchor, object region, lift, gripper, or stage gate.
- Robot-only anchor transitions: `open microwave -> pick cookies` at frame 70 and `place cookies -> pick chocolate` at frame 0. The anchor becomes eligible only after VLM output and EEF hold/release.
- `Close_Microwave` is optional for Task20 stage success in this wrapper; the four mandatory stages are open, place cookies, place chocolate.

## Checkpoint identifiers

- VLA: `fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338`, step `35999`.
- VLM: `task20_v49c6_strict_autonomous_20260714`.
- Norm SHA256: `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.

The original checkpoint paths, weights, data, videos, Slurm records, and machine-specific paths are intentionally excluded.
