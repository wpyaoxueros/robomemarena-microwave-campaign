# All-18 Direct-Use Exact20 Campaign

## Purpose

This campaign verifies that every reproducibility package currently retained in
this repository can be launched from its recorded assets and can produce a
traceable 20-episode result. A run already launched from the current frozen
repository package remains eligible: it counts when it reaches 20 valid
official episode summaries. Historical result tables are evidence only; they
do not substitute for a current repository run in this campaign.

## Scope

The 18 unique task IDs are:

`1, 2, 3, 6, 7, 10, 12, 13, 14, 16, 18, 20, 21, 22, 23, 24, 25, 26`.

Task12 and Task13 already completed valid instances from the same frozen chain.
Task6, Task7, Task10, Task16 and Task26 already have current runs launched
from their registered frozen packages. Each of these rows counts as complete
once that current run reaches 20 valid official summaries; it must not be
restarted just because the campaign policy was clarified after launch. Every
other task that does not have such a current valid run must start a new
20-episode reproduction from its registered package.

## Evaluation Contract

- VLA is the original `fullvlm-v2 noflip` checkpoint at step `35999` unless a
  task's frozen manifest explicitly says otherwise.
- Its norm is
  `assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`, SHA256
  `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.
- Task2 keeps its package-specific frozen evaluator/BDDL route. All other
  tasks use `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
  with `evaluation_benchmark/scripts/task2_26_reference_stage.py`; if a
  frozen microwave package pins an older scorer, the campaign creates a new
  versioned d9 scorer overlay and records the exact delta.
- Each run records the actual VLA/VLM/norm/scorer paths, launcher and evaluator
  hashes, submit user, Slurm job, node/GPU, episode summaries and artifact
  paths. No checkpoint path is hidden from the local campaign record.
- Raw outputs are written under the submitting account's
  `/data/user/<submit-user>/hlei573_borrow_outputs/` root because the shared
  NFS mount does not grant reliable cross-account write access even when the
  accounts share `irpn`. The Git result record stores each resulting absolute
  output path and summary path.
- VLM selects prompts. `ORACLE_*` next-prompt injection and object-moving
  anchors are prohibited from a successful result.

## Topology Policy

Use the frozen package's original VLA/VLM topology unless a one-GPU smoke has
already produced an eligible official summary. A one-GPU remap is only a
compatibility diagnostic until that gate passes; it must not replace a proven
two-GPU runtime solely to save cards.

Task6 job `437037` and Task21 job `437095` are the recorded counterexamples:
both remapped VLA, VLM, and EGL to one visible GPU, then failed before an
eligible 20-episode result. Task21 launched 13 episode attempts and produced
zero official summaries before cancellation. Future Task21 replays therefore
use its frozen two-GPU topology. The original package remains unchanged; any
job-local overlay and its SHA256 are committed before use.

## Counting Rules

- A current run launched from the registered frozen package is a continuation
  row. It becomes counted only after 20 valid official episode summaries.
- Task12 and Task13 are already completed continuation rows.
- Every other row begins with `NUM_TRIALS=20` or the package's explicit
  independent-one-episode worker protocol when it needs a fixed seed.
- An evaluator/process abort without an official episode summary is not a
  valid episode. It is separately logged and retried using the same frozen
  version until 20 valid rows exist.

## Publication

1. Commit and push this pre-run directory before any new job.
2. Commit and push each task's result record after its valid 20th episode.
3. Maintain `results/ALL18_RESULTS.md` as the single status and result table.

The local absolute paths used for every launch are tracked in
`LOCAL_ASSET_REGISTRY.md`; a package with an unresolved asset is not eligible
for launch until that registry row is repaired and committed.
