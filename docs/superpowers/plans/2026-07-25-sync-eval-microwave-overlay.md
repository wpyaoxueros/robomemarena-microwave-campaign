# Sync Eval Microwave Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the microwave evaluator a drop-in replacement for RoboMemArena's `tasks2_26_vlm5_reference` sync-eval directory.

**Architecture:** Preserve the upstream sync-eval runner environment contract and place all microwave-specific hold/release behavior behind an evaluator overlay with the same entrypoint name. The overlay ships a frozen copy of the upstream base evaluator, latest official BDDL/stage source checks, target configuration, and a runner that accepts the upstream `VLA_CKPT`/`VLM_CKPT` interface without external task-pack paths.

**Tech Stack:** Bash, Python 3.12, RoboMemArena d9f83ac, OpenPI policy websocket, Qwen VLM, LIBERO/MuJoCo.

---

### Task 1: Freeze the upstream-compatible overlay inputs

**Files:**
- Create: `sync_eval_overlay/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla_base.py`
- Create: `sync_eval_overlay/tasks2_26_vlm5_reference/fullvlm_v2_26_memory_tasks.json`
- Create: `sync_eval_overlay/tasks2_26_vlm5_reference/tasks2_26_endpose_targets_seed100_199.json`
- Test: `tests/test_sync_eval_overlay_layout.sh`

- [ ] Copy the d9f83ac upstream base evaluator and task configuration byte-for-byte into the overlay.
- [ ] Copy the versioned Task2 adapter and target JSON into the same overlay tree.
- [ ] Record SHA256 values for each copied file in `sync_eval_overlay/MANIFEST.tsv`.
- [ ] Verify the layout test checks every required file and rejects references to `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/task123_exact`.

### Task 2: Implement the drop-in evaluator entrypoint

**Files:**
- Create: `sync_eval_overlay/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py`
- Test: `tests/test_sync_eval_overlay_entrypoint.py`

- [ ] Load the packaged base evaluator through `TASKS2_26_BASE_EVAL_PY` rather than an external absolute path.
- [ ] Preserve all upstream environment variable names: `VLM_CKPT`, `VLA_CKPT`, `TASKS_JSON`, `NUM_TRIALS`, `SEED`, `REPLAN_STEPS`, `MAX_STEPS`, `POST_GOAL_STEPS`, `OUT_ROOT`, `VIDEO_DIR`, `SUMMARY_JSON`, and `SUMMARY_TSV`.
- [ ] Require `ROBOMEMARENA_OFFICIAL_ROOT` and verify that its Git HEAD, Task2 BDDL SHA, and stage-scorer SHA match the packaged manifest before starting a rollout.
- [ ] Test that the evaluator imports under a temporary environment and fails with a clear error when the official source or an expected checksum is absent.

### Task 3: Implement the upstream-compatible sync runner

**Files:**
- Create: `sync_eval_overlay/tasks2_26_vlm5_reference/run_tasks2_26_vlm_vla_csr_tsr.sh`
- Test: `tests/test_sync_eval_overlay_runner.sh`

- [ ] Start from the upstream runner interface without renaming required variables or changing output layout.
- [ ] Set the evaluator path to the packaged overlay entrypoint and its base evaluator path before execution.
- [ ] Default `ENDPOSE_HOLD_TARGETS_JSON` to the packaged JSON while allowing an explicit override.
- [ ] Keep VLA/VLM GPU placement configurable via the existing `SERVER_CUDA_VISIBLE_DEVICES` and `EVAL_CUDA_VISIBLE_DEVICES` variables.
- [ ] Test `bash -n`, required-variable failures, and the generated command/environment snapshot without starting a model.

### Task 4: Prove merge compatibility in an isolated replacement directory

**Files:**
- Create: `sync_eval_overlay/install_into_sync_eval.sh`
- Create: `sync_eval_overlay/README.md`
- Test: `tests/test_sync_eval_overlay_install.sh`

- [ ] Install only the overlay files into a temporary copy of the upstream `tasks2_26_vlm5_reference` directory.
- [ ] Assert the replacement directory contains the upstream entrypoint names and no dependency on campaign-local paths.
- [ ] Run one non-GPU configuration smoke and one real 1ep Task2 smoke using only the replacement directory plus explicit checkpoint paths.
- [ ] Compare the smoke's BDDL/scorer paths and output schema with the upstream sync-eval contract.

### Task 5: Publish a reproducible integration record

**Files:**
- Modify: `README.md`
- Create: `docs/SYNC_EVAL_INTEGRATION.md`

- [ ] Document the exact merge target, required checkpoint arguments, official-source pin, output files, and smoke command.
- [ ] Record the commit, overlay manifest SHA, and 1ep smoke result.
- [ ] Commit only the overlay, tests, and integration record; push to `origin/main`.
