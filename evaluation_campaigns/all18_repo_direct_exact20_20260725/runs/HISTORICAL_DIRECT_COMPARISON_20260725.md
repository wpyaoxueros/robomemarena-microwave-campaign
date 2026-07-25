# Historical Direct-Comparison Runs: 2026-07-25

This record separates valid frozen-topology replays from the earlier campaign
single-GPU compatibility attempts. A result is eligible for comparison only if
the listed account-side output contains its runtime manifest and summary.

## Active Replays

| Task | Submit account | Job | Topology | Frozen scorer | Output root | State at launch |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `zzhang510` | `437154` | two GPU, original archived launcher | `66e7894f8188be8114911e5df0f8bf89fe4581ce` | `/data/user/zzhang510/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/archived_repro20_historical/task1_historical66e789_exact20_20260725_084435` | running |
| 6 | `xiangqim` | `437171` | VLA first visible GPU; VLM/eval second visible GPU | `d9f83ac5182e25ad7f0a301a77a0b667f2392df1` | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/counting_historical_two_gpu/task6_historical_d9f83ac_exact20_20260725_090223` | running |

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
- Any archived or counting run using `*_single_gpu*` is recorded only as a
  compatibility diagnostic, not a historical-success reproduction.

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

Final per-task 20-episode metrics are added only after the actual submit
account confirms completion and the original summary files are present.
