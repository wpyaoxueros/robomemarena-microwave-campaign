# Microwave Original-35999 Iteration Pack

Purpose: isolate microwave Task20-24 evaluation iterations using the original fullvlmv2 VLA checkpoint and the sync-hold logic that produced the historical Task20/Task21 successes.

The VLA checkpoint and norm repository are supplied through an ignored private
input file. Their identity is recorded in each private run manifest, not in
this shareable repository.

The pack has three modes:

- `oracle`: `ORACLE_HOLD_RELEASE_NEXT=1`. After an endpose hold starts, the next primitive prompt is forced from the task primitive order. This tests whether the VLA plus hold/reset path can complete the task if the correct next prompt is supplied.
- `vlm_free`: `ORACLE_HOLD_RELEASE_NEXT=0`. VLM output is not forced; this is the mode for measuring whether the VLM independently emits the correct next prompt.
- `vlm_guarded`: VLM output is still the only source of new prompts. The evaluator rejects a wrong initial VLM subtask before `labels[0]`, blocks forward jumps until the current official stage is done, blocks sequence regression, and requires pick subtasks to release through hold before moving forward. It does not force the initial prompt and does not synthesize the next prompt after stage/hold completion. This mode defaults `VLM_COMPLETED_SUBTASKS_MODE=completed_struct`, which only injects a structured list of already completed subtasks into the VLM input after hold or official stage completion.

For autonomous microwave debugging, prefer the `release_anchors_*_robotonly*.json` configs first. They reset robot/gripper state to training subtask frames after VLM has emitted the next prompt and the previous subtask has held/released or finished its official stage, but they do not move object bodies into the microwave. The older `release_anchors_*_object_mw*.json` configs are diagnostic/oracle-style helpers because they may directly reposition object bodies into the microwave heating region.

Every run writes a manifest and a code snapshot under its output directory. Do not edit generated run folders.

Official scoring is pinned by the caller-provided RoboMemArena worktree. The
launcher verifies the expected commit, exports `ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR`, and requires
`task2_26_reference_stage.py`. Missing this file is a hard error; the evaluator
must not fall back to older `eval_tasks2_26.py` microwave-door logic.

For microwave tasks, TSR is stage-only. Goal/BDDL success is logged for audit
but ignored for final success. Task20/21/22/23/24 also treat
`Close_Microwave` as optional, so completing the open/place stages is enough
for TSR success.
