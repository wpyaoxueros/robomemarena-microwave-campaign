# All-18 Direct-Use Exact20 Campaign

## Purpose

This campaign verifies that every reproducibility package currently retained in
this repository can be launched from its recorded assets and can produce a
traceable 20-episode result. Historical result tables are evidence only; they
do not substitute for a new run in this campaign.

## Scope

The 18 unique task IDs are:

`1, 2, 3, 6, 7, 10, 12, 13, 14, 16, 18, 20, 21, 22, 23, 24, 25, 26`.

Task12 and Task13 already completed valid instances from the same frozen chain.
They count as the two completed continuation rows. Every other task must start
a new 20-episode reproduction from its registered package.

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
- VLM selects prompts. `ORACLE_*` next-prompt injection and object-moving
  anchors are prohibited from a successful result.

## Single-GPU Policy

Each worker receives one Slurm GPU and binds both VLA and VLM to it. Original
packages that hard-code VLA to device `0` and VLM to device `1` are copied into
`overlays/` and receive only a device-selection parameterization. The original
package remains unchanged; the patch and its SHA256 are committed before use.

## Counting Rules

- The current Task12 and Task13 processes are continuation rows, not restarts.
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
