# Microwave Checkpoint Registry

Last verified: 2026-07-25.

This is the authoritative local asset map for the Task20--Task24 microwave
campaign. Checkpoint files and raw datasets are not committed, but their exact
source paths are committed here deliberately. Before sharing a version outside
this machine, upload the matching VLA and VLM directories to Hugging Face and
replace the local paths in that version's environment file with the resulting
paths or repository revisions.

Do not infer a successful recipe from a checkpoint name. A row is valid only
with the listed evaluator commit and versioned launcher. `diagnostic` rows are
kept for provenance and are not a success claim.

## Shared Original VLA35999 Assets

- VLA policy:
  `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`
- VLA config: `pi05_libero_robomemarena_fullvlm_v2_noflip_dataset`
- Matching norm repository:
  `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999/assets/robomemarena_fullvlm_v2_noflip_dataset_v2`
- Matching `norm_stats.json` SHA256:
  `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`

The cache mirror at
`/data/user/hlei573/.cache/huggingface/lerobot/lhs/robomemarena_fullvlm_v2_noflip_dataset_v2`
has the same verified `norm_stats.json` hash, but the checkpoint-contained
`assets/...` path above is the default for new reproductions.

## Task20

### v49c6 strict autonomous, historical scorer

- Status: frozen success; historical scorer only, not a latest-scorer result.
- VLA: shared VLA35999 path above.
- VLM:
  `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_orig35999_anchor_iter/frozen/task20_v49c6_strict_autonomous_20260714/repro_20260721/runtime/frozen/task20_v49c6_strict_autonomous_20260714/checkpoint`
- Norm:
  `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_orig35999_anchor_iter/frozen/task20_v49c6_strict_autonomous_20260714/repro_20260721/norm_assets/robomemarena_fullvlm_v2_noflip_dataset_v2`
  (`norm_stats.json` SHA256 matches the shared asset).
- Scorer: `514ecdf86ba47d496ab1728a827670833107ffd3`.
- Evidence manifest:
  `/data/user/zzhang510/hlei573_borrow_outputs/microwave_frozen_reproductions_20260721/task20_v49c6_exact_repro_20260721_174537/run_manifest.json`

### v107 / v110 latest-622 family

- Status: VLM-autonomous, no oracle prompt injection; use only the listed
  versioned launcher/config with this asset pair.
- VLA: shared VLA35999 path above.
- v107 VLM frozen copy:
  `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_frozen_runtimes_20260721/task20_v107_20260721_1606/vlm_eval_ready_local/v49_selfcontained/task20_mwvlm_no_completed_v49_ckpt24`
- v110 VLM source copy:
  `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_orig35999_anchor_iter/vlm_eval_ready_local/v49_selfcontained/task20_mwvlm_no_completed_v49_ckpt24`
- Norm: shared VLA35999 norm path above.
- Scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Evidence manifests:
  - v107:
    `/data/user/zzhang510/hlei573_borrow_outputs/microwave_frozen_reproductions_20260721/task20_v107_task24_v131_exact_frozen_20260721_163635/mw_orig35999_t20_v107_frozen_seed106_20260721_163635/run_manifest.json`
  - v110:
    `/data/user/zzhang510/hlei573_borrow_outputs/microwave_task20_v110_placecookies11/mw_orig35999_t20_v110_placecookies11_seed106_20260722_060007/run_manifest.json`

## Task21

### v121 frozen autonomous reproduction

- Status: frozen latest-622 success for seeds 104 and 107; VLM generates
  prompts and all `ORACLE_*` switches are zero.
- VLA: shared VLA35999 path above.
- VLM:
  `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260701_082527_task21r17c_task21_r17_openkeep_latepick_rawtrace_open_microwave_to_pick_butter/hzhang061/eval_artifacts/vlm_eval_ready/task21_task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000_20260701_100519/task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000`
- Norm: shared VLA35999 norm path above.
- Scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Evidence manifests:
  - seed104:
    `/data/user/zzhang510/hlei573_borrow_outputs/microwave_frozen_reproductions_20260721/task21_v121_exact_frozen_20260721_162050/mw_orig35999_t21_v121_nopick2place_upward_pickfinish_seed104_20260721_162050/run_manifest.json`
  - seed107:
    `/data/user/zzhang510/hlei573_borrow_outputs/microwave_frozen_reproductions_20260721/task21_v121_exact_frozen_20260721_162050/mw_orig35999_t21_v121_nopick2place_upward_pickfinish_seed107_20260721_162050/run_manifest.json`

## Task22

### v33 35999 physical-pick diagnostic

- Status: diagnostic only. It is **not** an accepted Task22 successful
  reproduction and must not be reported as one.
- VLA: shared VLA35999 path above.
- VLM:
  `/data/user/hlei573/openpi_inference/output/tasks4_26_noorder_base_eval_artifacts/vlm_eval_ready/task22_task22_noorder_adaptive_20260621_044315_ckpt1000_20260621_071820/task22_noorder_adaptive_20260621_044315_ckpt1000`
- Norm: shared VLA35999 norm path above.
- Scorer: `8b7710924f862ab1c8dea69adada62e8c462de40`, the Task22 remote-patch
  snapshot used by this diagnostic, not the later `6221403` frozen scorer.
- Evidence manifest:
  `/data/user/zzhang510/hlei573_borrow_outputs/task22_v33_35999_physicalpick_noheldobjectteleport/task22_v33_35999_physicalpick_noheldobjectteleport_g2_seed104_20260724_092827/run_manifest.json`

When a Task22 version reaches an accepted autonomous success under its pinned
latest scorer, add a separate row rather than relabeling this diagnostic row.

## Task23

### v155 fixed seed105, 20 independent episodes

- Status: accepted autonomous stage-only result: `15/20 = 75.0%`; close is
  optional. VLM emits prompts; no oracle next-prompt injection or object anchor.
- VLA: shared VLA35999 path above.
- VLM:
  `/data/user/zzhang510/hlei573_borrow_outputs/microwave_vlm_aug_runs/task23_v144_pickpopcorn_done_weighted_20260721_221830/train/task23_v144_pickpopcorn_done_weighted_20260721_221830/checkpoint-400`
- Norm: shared VLA35999 norm path above.
- Scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Asset manifest exemplar:
  `/data/user/zzhang510/hlei573_borrow_outputs/microwave_task23_continuations/task23_v155_fixedseed105_repeat20_20260721_235119/replacements_20260722/slot2_20260722_011757/run_manifest.json`
- Result ledger:
  `tasks/task23/v155_fixedseed105_repeat20/history/RESULT.md`

## Task24

### v131 frozen autonomous reproduction

- Status: frozen latest-622 success at seed108; VLM supplies all prompts and
  `ORACLE_*` switches are zero.
- VLA: shared VLA35999 path above.
- VLM:
  `/data/user/zzhang510/hlei573_borrow_outputs/microwave_vlm_aug_runs/task24_v131_eval_ready_20260718_120049/lr5e7_ckpt6`
- Norm: shared VLA35999 norm path above.
- Scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Evidence manifest:
  `/data/user/zzhang510/hlei573_borrow_outputs/microwave_frozen_reproductions_20260721/task20_v107_task24_v131_exact_frozen_20260721_163635/mw_orig35999_t24_v131_frozen_seed108_20260721_163635/run_manifest.json`

## Rule for Every New Version

Before a new eval is submitted, add its exact VLA policy path, VLM checkpoint
path, norm repository path and SHA256, scorer commit, and expected output root
to that version's `PRE_RUN.md` or `RUN_MANIFEST.md`. After the run, add the
actual `run_manifest.json` path and commit the result record before starting a
new variant. Do not replace an existing row or use an identifier in place of a
path.
