# Task22 v18 Stage-Prompt Diagnostic Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Execute this plan task-by-task with the stated validation gates and commit every completed experiment record.

**Goal:** Determine whether the original `35999` policy can physically complete all required Task22 stages when supplied the correct primitive prompt.

**Architecture:** Keep the latest remote Task22 scorer and original `35999` policy inputs. A version-local evaluator replaces only the prompt source with a stage-driven diagnostic schedule. Cookies switch from pick to place only after an EEF target check; no object state is fabricated.

**Tech Stack:** Python, MuJoCo/LIBERO, OpenPI websocket policy server, Slurm, tmux, Git.

---

### Task 1: Validate the diagnostic prompt selector

**Files:**
- Create: `versions/v18_35999_stageprompt_diagnostic/runtime/task22_stageprompt.py`
- Create: `versions/v18_35999_stageprompt_diagnostic/tests/test_task22_stageprompt.py`

- [ ] Run the unit test and require `TASK22_STAGEPROMPT_UNIT_OK`.
- [ ] Confirm the selector maps the first five remote stages to pick tomato, pour first, pour second, place tomato aside, and open microwave.
- [ ] Confirm pick cookies changes to place cookies only after its EEF condition.

### Task 2: Isolate the evaluator behavior

**Files:**
- Create: `versions/v18_35999_stageprompt_diagnostic/runtime/eval_tasks2_26_task22_stageprompt_diagnostic.py`
- Modify: `versions/v18_35999_stageprompt_diagnostic/run_1ep.sh`

- [ ] Require the repaired remote scorer commit and checkpoint-owned `35999` norm before rollout.
- [ ] Leave all VLM prompt oracle flags at zero; label the explicit stage schedule as diagnostic-only.
- [ ] Disable generic end-pose hold, object anchors, object gates, lift gates, gripper gates, and completed-task injection.
- [ ] Compile the evaluator and run the target verifier before submitting.

### Task 3: Run one reproducible diagnostic episode

**Files:**
- Create after launch: `versions/v18_35999_stageprompt_diagnostic/RUN_STARTED_<timestamp>.md`
- Create after completion: `versions/v18_35999_stageprompt_diagnostic/RUN_RESULT_<timestamp>.md`

- [ ] Run the required 1-GPU and 2-GPU probes from `zzhang510` in the submitting shell.
- [ ] Launch the formal episode through tmux plus srun.
- [ ] Save stage summary, prompt trace, video, output hashes, and a Git commit for both start and result.
- [ ] Treat a stage-success result as VLA capability evidence only, then implement the separately labelled VLM-owned partial rescue.
