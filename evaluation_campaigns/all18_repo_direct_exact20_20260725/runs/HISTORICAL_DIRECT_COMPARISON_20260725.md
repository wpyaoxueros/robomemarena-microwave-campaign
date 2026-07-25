# Historical Direct-Comparison Runs: 2026-07-25

This record separates valid frozen-topology replays from the earlier campaign
single-GPU compatibility attempts. A result is eligible for comparison only if
the listed account-side output contains its runtime manifest and summary.

## Active Replays

| Task | Submit account | Job | Topology | Frozen scorer | Output root | State at launch |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `zzhang510` | `437154` | two GPU, original archived launcher | `66e7894f8188be8114911e5df0f8bf89fe4581ce` | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_repro20_historical/task1_historical66e789_exact20_20260725_084435` | complete: 14/20, TSR=70.0%, CSR=82.5% |
| 6 | `xiangqim` | `437171` | VLA first visible GPU; VLM/eval second visible GPU | `d9f83ac5182e25ad7f0a301a77a0b667f2392df1` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/counting_historical_two_gpu/task6_historical_d9f83ac_exact20_20260725_090223` | complete: 17/20 stage-success and goal-success; all 20 exits clean |
| 12 | `xiangqim` | `437367` | two GPU, generic archived topology | `66e7894f8188be8114911e5df0f8bf89fe4581ce` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task12_originalsnapshot66e789_exact20_20260725_105349` | excluded: generic materializer loaded copied `5a927...`, not original runtime `EVAL_PY=ef956...` |
| 2 | `zzhang510` | `437250` | two GPU, generic archived topology | `66e7894f8188be8114911e5df0f8bf89fe4581ce` | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task2_originalsnapshot66e789_exact20_20260725_095829` | excluded: generic materializer loaded copied `cda4...`, not original runtime `EVAL_PY=ef956...` |
| 3 | `zzhang510` | `437278` | two GPU, generic archived topology | `66e7894f8188be8114911e5df0f8bf89fe4581ce` | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task3_originalsnapshot66e789_exact20_20260725_100422` | excluded: generic materializer loaded copied `5a927...`, not original runtime `EVAL_PY=ef956...` |
| 18 | `xiangqim` | `437253` | two GPU, generic archived topology | `66e7894f8188be8114911e5df0f8bf89fe4581ce` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task18_originalsnapshot66e789_exact20_20260725_095844` | excluded: generic materializer loaded copied `5a927...`, not original runtime `EVAL_PY=ef956...`; it also had the wrong lift gate |

## Corrected Runtime-Driver Restarts

All rows below use campaign commit `c3fb8b9d4b39e72f51df3af1a0ef0195d9d98fb0`.
Each execution-pack manifest and runtime plan records
`frozen_evaluator_sha256=original_runtime_evaluator_sha256=ef95604ca17c7900eac172d0e082a3738ca5b62e8468bf4f53c522590ff7dd2b`.
They are the only archived Task2/3/12/13/18/25/26 results eligible for the
new strict comparison; do not combine them with the excluded generic runs.

| Task | Submit account | Job | Output root | Status at restart |
| ---: | --- | ---: | --- | --- |
| 13 | `zzhang510` | `437518` | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task13_originalsnapshot66e789_exact20_20260725_113400_rtefix` | running; original lift gate `1`, `completed_struct` |
| 25 | `zzhang510` | `437528` | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task25_originalsnapshot66e789_exact20_20260725_113600_rtefix` | running; original lift gate `1` |
| 12 | `xiangqim` | `437531` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task12_originalsnapshot66e789_exact20_20260725_113700_rtefix` | running; original drawer-passage file, lift gate `1`, `completed_struct` |
| 18 | `xiangqim` | `437534` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task18_originalsnapshot66e789_exact20_20260725_113800_rtefix` | running; original lift gate `0` |
| 2 | `xiangqim` | `437541` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task2_originalsnapshot66e789_exact20_20260725_113900_rtefix` | running; original gates `0` |
| 3 | `xiangqim` | `437542` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task3_originalsnapshot66e789_exact20_20260725_113901_rtefix` | running; original gates `0` |
| 26 | `xiangqim` | `437545` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_original_snapshot/task26_originalsnapshot66e789_exact20_20260725_114000_rtefix` | running; original lift gate `1` |

Duplicate Task13 job `437521` was cancelled before scoring; it must not be
counted or used as a second replicate.

## Pinned 6221403 Runtime for Microwave Replays

Task20/21/23/24 frozen packages require the exact OpenHelix scorer commit
`62214036103ee8d5fef9b475dd8b344b6e2cfc03`; they must not fall back to a later
checkout or to the old scorer. The isolated detached worktree is:

```text
/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_6221403_20260725
```

It is clean at that commit, contains
`evaluation_benchmark/scripts/task2_26_reference_stage.py`, and that script's
SHA256 is
`0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.
Both `zzhang510` and `xiangqim` have verified read access and can run
`git rev-parse HEAD` using only a local safe-directory override. The worktree
is isolated from the stable source repository and is not modified by a replay.

## Queued Follow-ups

Each queued replay waits for the exact predecessor's two-GPU allocation to
finish, then runs fresh one- and two-GPU probes in the submitting account
before it can launch. This preserves the original VLA/VLM two-GPU topology
without creating unverified pending formal jobs.

| Task | Submit account | Waits for | Wait session | Frozen campaign commit |
| --- | --- | --- | --- | --- |
| 13 | `zzhang510` | Task2 job `437250` | `lhs_wait_t13_after_t437250_v2_20260725_102814` | `cab03422b8150b2c4432f866568cefced76a694c` |
| 25 | `zzhang510` | Task3 job `437278` | `lhs_wait_t25_after_t437278_v2_20260725_102814` | `cab03422b8150b2c4432f866568cefced76a694c` |
| 26 | `xiangqim` | Task18 job `437253` | `lhs_wait_t26_after_t437253_v2_20260725_102812` | `cab03422b8150b2c4432f866568cefced76a694c` |
| 16 | `xiangqim` | completed Task12 original-snapshot 20ep summary | `lhs_wait_t16_after_t12_originalsnapshot_20260725_103300` | `25ed8f07629f50441fd7202f7c6d3a54a590cf74` |
| 14 | `zzhang510` | completed Task13 original-snapshot 20ep summary | `lhs_wait_t14_after_t13_originalsnapshot_20260725_103700` | `20961c6a30a7d392bd3f7ae1c583ec6bffde0a9a` |

The first generation of wait sessions (`..._101000` and `..._101500`) wrote
only their initial wait line and then exited before submission. They are
superseded by the listed `v2` sessions, which remain alive, recheck the
predecessor from the submit account, and retry the mandatory fresh probes until
an exact two-GPU formal submission succeeds.

Task26's waiter observed the Task18 cancellation and submitted job `437459`
before the waiter could be removed. Although its gate configuration was
correct, it used the same generic copied driver rather than `EVAL_PY=ef956...`.
It is excluded and must restart from the corrected execution pack.

## Excluded Runs

- Task6 job `437037` used the campaign's single-GPU overlay, which remapped
  VLA, VLM, and EGL to one GPU. It was stopped on 2026-07-25 and must not be
  compared with the frozen Task6 `17/20` record.
- Task6 job `437167` used the correct two-GPU allocation but the imported
  code-only snapshot lacked the frozen evaluator's expected
  `source/RoboMemArena_d9f83ac` path. It exited before a rollout or summary,
  was stopped, and is excluded. The next revision materializes that path as a
  job-local symlink to the already hash-pinned d9 source without changing any
  evaluator file.
- Task2 job `437161` and Task18 job `437151` both used two GPUs but loaded a
  later launcher/evaluator at the historical source pathname. They were
  stopped after three completed episodes each and are excluded: Task2 had a
  new `ENDPOSE_HOLD_START`/release path absent from the original successful
  trace, while Task18 used the same changed launcher. Their replacement route
  is documented in `ARCHIVED_ORIGINAL_SNAPSHOT_TOPOLOGY.md`.
- Task2 job `437181` and Task18 job `437179` used the correct archived
  launcher/evaluator hashes but the first materializer flattened the base
  evaluator away from its original `RoboMemArena/evaluation_benchmark` layout.
  Both exited before episode zero with a missing local runtime module and have
  no rollout result. They are excluded; the corrected materializer reconstructs
  the original layout and records every copied runtime-module hash.
- Task2 job `437188` and Task18 job `437191` used that corrected evaluator and
  runtime-module hierarchy, but the first correction omitted the top-level
  archived `RoboMemArena/bddl` directory. The original runtime's untouched
  root resolver requires both `evaluation_benchmark` and `bddl`; Task2 exited
  before episode zero and Task18 was cancelled during VLA startup before any
  rollout. Both are excluded. The next pack copies and hashes the complete
  original BDDL root as well.
- Task2 job `437195` confirms that the BDDL root was then present, but it also
  exposed a second layout-sensitive import: placing the archived outer
  evaluator next to `code_snapshot/eval_common.py` changed the import target
  relative to the original `SOURCE_ROOT/evaluators` directory. It exited before
  episode zero. Task18 job `437198` was stopped during startup before entering
  the same evaluator path. Both are excluded; the next pack runs the unchanged
  outer evaluator from an isolated driver directory with no sibling
  `eval_common.py`.
- Task2 job `437210` passed the isolated-driver import but reached the outer
  evaluator's `main()` rebind, where its flattened official script copy again
  resolved BDDL relative to the wrong parent. It exited before episode zero.
  Task18 job `437213` was stopped during startup before that path was entered.
  Both are excluded. The next pack reconstructs the original official
  `evaluation_benchmark/scripts` plus sibling `bddl` hierarchy and verifies the
  rebound resolver in an import-layout test before submission.
- Any archived or counting run using `*_single_gpu*` is recorded only as a
  compatibility diagnostic, not a historical-success reproduction.
- Task12 job `437347` passed fresh one- and two-GPU probes but exited before
  episode zero. The external replay wrapper had hard-coded the later
  `tasks2_26_target...` passage filename, while Task12's original snapshot
  contains `passage_counts__drawer_passage_counts_task4full_plus_alltasks_20260627.json`.
  It produced no rollout or summary and is excluded. The repaired wrapper now
  selects the unique `passage_counts__*.json` copied from each task's own frozen
  snapshot; Task12/13 resolve to the drawer file and Task18/25/26 resolve to
  their original target-count file.
- Task18 job `437253` also used the generic copied outer driver rather than the
  original runtime `EVAL_PY`, and the generic campaign wrapper incorrectly set
  `ENDPOSE_PICK_OBJECT_LIFT_GATE=1`. The actual Task18 snapshot, its saved
  environment, and its previous 5/5 replay all require `0`. It was cancelled
  after ten completed episodes and is excluded. The corrected wrapper now has
  a dry-run contract assertion for both `pick_lift_gate=0` and the original
  runtime evaluator hash before restart.

## Integrity Checks

- Task6 job `437167` passed a fresh account-local one-GPU probe and a two-GPU
  probe before formal submission.
- Its runtime manifest pins the fullvlm-v2 `35999` VLA checkpoint, matched norm
  SHA256 `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`,
  frozen Task6 runner SHA256
  `a6527351b3a65f6096a07e443daffb760928482bec8c9e3d78991113af63c559`,
  and d9 scorer SHA256
  `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.
- The archived runs pin their historical source scripts and the `66e7894`
  stage scorer in each `historical_runtime_manifest.env`.
- The archived replay topology contract now dry-runs Task12 and asserts the
  selected passage file is the original snapshot's drawer-count JSON. A dry-run
  matrix also verifies the per-snapshot passage asset for Task12/13/18/25/26.

Final per-task 20-episode metrics are added only after the actual submit
account confirms completion and the original summary files are present.

## Live Progress Snapshot (2026-07-25 10:59 CST)

This snapshot was read from the actual submit-account output roots. Counts use
main-view episode videos only; wrist copies are not counted as extra episodes.
These are in-progress counts, not final 20-episode claims.

| Task | Job | Completed main episodes | Main-view successes | Status |
| --- | --- | ---: | ---: | --- |
| 2 | `437250` | 11/20 | 11/11 | excluded: wrong outer evaluator driver |
| 3 | `437278` | 10/20 | 7/10 | excluded: wrong outer evaluator driver |
| 12 | `437367` | 0/20 | - | excluded: wrong outer evaluator driver |
| 18 | `437253` | 9/20 | 5/9 | excluded: wrong outer evaluator driver and lift gate |
