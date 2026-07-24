# Counting Direct-Use Single-GPU Batch: Source Overlay Fix

## Purpose

Run the committed counting packages for Tasks 6, 7, 10, and 16 directly on
one allocated GPU per task. Both VLA and VLM use CUDA device `0` inside the
one-GPU Slurm cgroup. Each task records the exact frozen package, VLM/VLA
paths, norm, scorer hash, overlay manifest, and raw output directory.

The job-local overlay is required because these frozen evaluators resolve the
official async evaluator as `PACK_DIR/source/RoboMemArena_d9f83ac/...`.
It copies the frozen package `scripts/` and `evaluators/` and adds a read-only
link to the fixed official source checkout. The original frozen package is not
modified.

## Code And Official Inputs

- Source-overlay commit: `e162195053a65ad4bdcd5e003c908ed33f9b5d63`
- Git-provenance overlay commit: `d01a68f181c9f3b5354b54c3f9b00c4c898a4b3d`
- Official source: `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- Official stage scorer:
  `/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725/evaluation_benchmark/scripts/task2_26_reference_stage.py`
- Official stage scorer SHA256:
  `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`
- VLA checkpoint:
  `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`
- Norm:
  `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json`

The norm path above is intentionally recorded verbatim from this document's
creation time. The runtime manifest is authoritative because it records the
actual resolved norm path and SHA256.

## Launches

| Task | Protocol | Submit user | Slurm job | Status | Output root |
| --- | --- | --- | ---: | --- | --- |
| 6 | seed100 x20 independent episodes | xiangqim | 437037 | running | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task6/task6_all18_direct20_single_gpu_20260725_062354` |
| 7 | seeds100--119 | pending | - | pending | - |
| 10 | seeds100--119 | pending | - | pending | - |
| 16 | seeds100--119 | pending | - | pending | - |

## Validity Rule

An attempt counts only when it writes an official episode summary from the
fixed scorer. A process failure before a summary is recorded as invalid and
does not consume one of the required 20 valid episodes.
