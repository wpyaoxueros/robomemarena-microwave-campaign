# Task6 Counting Reproduction Snapshot

This directory imports the Task6 autonomous counting evaluator into the
microwave campaign monorepo without mixing it into `tasks/task20`--`task24`.
It is a code and configuration snapshot only: no checkpoint, raw video,
absolute local path, credential, or full runtime log is committed here.

## Frozen source

- Source repository: `robomemarena-counting-vlm35999-latest-repro`
- Source commit: `c9ce734ca18df61f72bf0f4e340960e72e7dde40`
- Remote RoboMemArena scorer: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- VLA contract: original fullvlm-v2 checkpoint `35999` with its matched norm
- Prompt source: trained Task6 VLM; all oracle prompt-injection flags are off
- Final-place prompt supervision: excluded from the Task6 no-place recipe

## Contents

- `evaluators/`: stage-only wrapper and non-injecting VLM prompt guard.
- `scripts/`: autonomous launcher, self-contained policy server, fixed-seed
  20-repeat worker, Slurm submitter, and official-summary aggregator.
- `tests/`: guard, policy configuration, and fixed-seed worker tests.
- `tools/`: generic Task6/Task7 Pour2 no-final-place data recipe builder.

The repeat aggregator treats each independently reset evaluator process as one
episode and reads its original official `summary.tsv` directly. This avoids
shell parsing errors caused by an empty TSV error column.

Before launching, set `SOURCE_ROOT`, `VLA_CKPT`, `VLM_CKPT`, `OPENPI_ROOT`,
and `OPENPI_INFERENCE_ROOT`. The repository intentionally has no machine-local
defaults for those values.

## Current fixed-seed run

The active Task6 experiment uses seed `100`, twenty independent `NUM_TRIALS=1`
processes, `REPLAN_STEPS=1`, and a 30-step post-required-stage third-pour
monitor. Its raw evidence remains in the source repository under the frozen
source commit above; this monorepo stores the executable snapshot needed to
reproduce it.
