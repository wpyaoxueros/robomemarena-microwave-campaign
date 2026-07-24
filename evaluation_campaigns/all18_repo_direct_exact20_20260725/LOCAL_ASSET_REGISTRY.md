# All-18 Local Asset Registry

This registry is intentionally local-path complete. It records the machine
assets required to launch the packages in this campaign; the model files are
not committed to Git. `verified` means the path was checked on 2026-07-25.

## Shared VLA and Scorer

| Role | Absolute local path / value | State |
| --- | --- | --- |
| VLA checkpoint | `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999` | verified |
| VLA norm | `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999/assets/robomemarena_fullvlm_v2_noflip_dataset_v2/norm_stats.json` | SHA256 `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a` |
| Current official source | `/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725` | `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1` |
| Current official scorer | `/data/user/hlei573/vla_memory_experiments/official_runtime_sources/RoboMemArena_openhelix_d9f83ac_20260725/evaluation_benchmark/scripts/task2_26_reference_stage.py` | SHA256 `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538` |

## Per-Task VLM Assets

| Task | VLM checkpoint path | Package / launcher | State |
| ---: | --- | --- | --- |
| 1 | `/data/user/hlei573/openpi_inference/tmp/vlm_eval_ready/task1_no_label_no_order_raw_regguard_ckpt1000_20ep_exact_seed104_20260701_090434/holdstatic_ckpt1000` | `success_packs/repro20_remote_metrics_20260704_175011/run_one.sh` | registered |
| 2 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task2_r1_exact20_eval_20260701_135219/vlm_eval_ready/task2_r1_ckpt500_20260701_143058` | same `run_one.sh`, frozen Task2 evaluator route | registered |
| 3 | `/data/user/hlei573/openpi_inference/output/tasks2_26_noorder_ablation_eval_artifacts/vlm_eval_ready/task3_20260621_014805/task03_no_label_no_order_raw_regguard_ckpt500_ckpt500` | `success_packs/repro20_remote_metrics_20260704_175011/run_one.sh` | registered |
| 6 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260621_181347/hlei/eval_artifacts/vlm_eval_ready/task6_task06_english_ref_20260621_192534_ckpt1000_20260621_202035/task06_english_ref_20260621_192534_ckpt1000` | `counting/task6_fixed_seed_latest_d9f83ac` | verified |
| 7 | `/data/user/zzhang510/hlei573_borrow_outputs/counting_task7_evalpour1hardcase256aligned_vlm_2gpu_acdu_20260724_093053/vlm_eval_ready/checkpoint-500` | `counting/task7_vlm35999_latest_d9f83ac_hardcase500_20260724` | registered; preflight required under submit user |
| 10 | `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/counting_vlm35999_latest_d9f83ac_2ep_20260723/evidence/training/task10_pickpour1_pour2_boundary_vlm_20260724_052511/checkpoint-750` | `counting/task10_vlm35999_d9f83ac_pourreturnassist_20260724` | verified |
| 12 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/task12_ckpt1000_exact20_completedstruct_parallel_20260701_193920_task12_ckpt1000_exact20_parallel/vlm_eval_ready/task12_seed104_borrow_20260701_1945/task12_english_ref_20260629_130504_exact20_completedstruct_seed104_ckpt1000` | `evaluation_campaigns/latest_openhelix_d9f83ac_exact20_20260725/scripts/run_archived_task_exact20.sh` | completed 20ep |
| 13 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_task13_task12style_completedstruct/hlei573/eval_artifacts/vlm_eval_ready/task13_task13_english_ref_20260702_113430_ckpt1000_20260702_123231/task13_english_ref_20260702_113430_ckpt1000` | same archived runner | completed 20ep |
| 14 | `task14_english_ref_20260702_140740_ckpt1000` (absolute directory not recorded in the frozen package) | `task14/versions/v1_latestscore_35999_20ep/scripts/run_task14_v1.sh` | blocked until the exact directory is recovered |
| 16 | `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/counting_vlm35999_latest_d9f83ac_2ep_20260723/runs_stageprompt/training_task16_pick_postlift_balanced_vlm_20260724_201612_emergency_acd/checkpoint-100` | `counting/task16_vlm35999_d9f83ac_pourreturnassist_20260724` | verified |
| 18 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260702_110452_task18_clean_completed_clean_task18_r9_clean_lateboundaries/hlei573/eval_artifacts/vlm_eval_ready/task18_20260702_130310_20ep_split_chunk0_seed104/task18_english_ref_20260702_110805_ckpt1000` | `tasks/task18/versions/v2_original_snapshot_topology_replay/run_original_snapshot.sh` | registered |
| 20 | `/data/user/hlei573/vla_memory_experiments/repro_eval_packs/microwave_orig35999_anchor_iter/vlm_eval_ready_local/v49_selfcontained/task20_mwvlm_no_completed_v49_ckpt24` | `tasks/task20/versions/v110_placecookies11_latest622` | blocked: frozen robot-anchor inputs `pick_cookies_1_seed104_task20.hdf5` and `pick_chocolate_3_seed104_task20.hdf5` are absent; only the long seed104 HDF remains and is not substituted |
| 21 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260701_082527_task21r17c_task21_r17_openkeep_latepick_rawtrace_open_microwave_to_pick_butter/hzhang061/eval_artifacts/vlm_eval_ready/task21_task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000_20260701_100519/task21_r17_openkeep_latepick_borrow_20260701_0848_borrowtrain_t21_ckpt1000` | `tasks/task21/scripts/run_task21_v121.sh` | verified |
| 22 | `/data/user/hlei573/openpi_inference/output/tasks4_26_noorder_base_eval_artifacts/vlm_eval_ready/task22_task22_noorder_adaptive_20260621_044315_ckpt1000_20260621_071820/task22_noorder_adaptive_20260621_044315_ckpt1000` | `tasks/task22/scripts/run_task22_v1_latest622.sh` | registered |
| 23 | `/data/user/zzhang510/hlei573_borrow_outputs/microwave_vlm_aug_runs/task23_v144_pickpopcorn_done_weighted_20260721_221830/train/task23_v144_pickpopcorn_done_weighted_20260721_221830/checkpoint-400` | `tasks/task23/v155_fixedseed105_repeat20` | registered; preflight required under submit user |
| 24 | `/data/user/zzhang510/hlei573_borrow_outputs/microwave_vlm_aug_runs/task24_v131_eval_ready_20260718_120049/lr5e7_ckpt6` | `tasks/task24` v131 contract | registered; preflight required under submit user |
| 25 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_0815_task25_enref_r3_holdearly_fixepscan/hzhang061/eval_artifacts/vlm_eval_ready/task25_task25_english_ref_20260624_080016_ckpt500_20260624_082818/task25_english_ref_20260624_080016_ckpt500` | archived d9 adapter | registered |
| 26 | `/data/user/hlei573/vla_memory_experiments/english_ref_vlm26/output_shared_20260624_1402_task26_enref_r4_hardcase_lowstage/zzhang510/eval_artifacts/vlm_eval_ready/task26_task26_english_ref_20260624_155719_ckpt500_20260624_162536/task26_english_ref_20260624_155719_ckpt500` | archived d9 adapter | registered |

## Completion Rule

Task12 and Task13 are already completed continuation rows. Task6, Task7,
Task10, Task16 and Task26 have current runs launched from their registered
frozen packages; each counts when it reaches 20 valid official episode
summaries. Historical metrics alone never count. Every task without a current
eligible run needs a new 20-valid-episode run whose manifest cites this
registry and whose result is committed here.
