# Frozen provenance

This package was extracted from the Task21 v121 frozen runtime on 2026-07-21 after two successful runs:

| Seed | Stage | Goal |
| --- | --- | --- |
| 104 | 100% | 100% |
| 107 | 100% | 100% |

Official scorer commit: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.

## Checkpoint identifiers

- VLA: `fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338`, step `35999`.
- VLM: `task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000_20260701_100519`.
- Norm SHA256: `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`.

These identifiers intentionally omit the original machine paths. The package requires local paths through `.env`.

## Source hashes

| Frozen source | SHA256 |
| --- | --- |
| v121 8-GPU driver | `9726a2a95c240f0d27173887b986acc0303c998fb1b930c43d1899add076dd5d` |
| v115 fan-out driver | `c2adcc432829f6cd5100e00b9dc1076339a9cdea1bf4699df22a9d3c3a43bcc0` |
| v108 Task21 entry | `ef02265e11f53a71a01412fcf76e6914b6e7c9378d3672f418e15b88a86afe8e` |
| v110 Task21 entry | `99198817b4de621ab20b8ca36ddfb36a38b9f12b538558554cec0baea509dda8` |
| EEF hold runner | `b5c6d90893b5fb22cde0f84046e5c325e6a2e7f7863e0ca50500bad1946d6bab` |
| launcher | `47cd0fac119522c583ead48df1e88c67faa21ec8a1cdc9e9f49c7dbb22c4ed47` |
| official-score wrapper | `4615bd92bd00e647742da740d08d782ae7133a4542a6a42c273721225b8d62db` |
| VLA norm stats | `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a` |

## Deliberate packaging changes

The frozen source itself remains unchanged outside this repository. This shareable package makes only interface changes that do not alter rollout policy:

1. The original 8-GPU driver also launched Task23 and Task24. `run_task21_v121.sh` retains the exact Task21 v121 environment and runs one specified Task21 seed only.
2. Machine-specific VLA, VLM, OpenPI, LIBERO, dataset and output paths are required environment variables or package-relative paths.
3. The robot-only anchor config is materialized from `TASK21_DATA_ROOT` at launch.
4. The official repository is external and must be exactly commit `6221403`; it is snapshotted into every output run.

No model weights, videos, training data or original checkpoint paths are included.
