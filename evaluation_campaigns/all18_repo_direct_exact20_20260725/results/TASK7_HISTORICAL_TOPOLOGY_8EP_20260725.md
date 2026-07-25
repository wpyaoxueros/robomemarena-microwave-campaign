# Task7 Historical Two-GPU Reference Result

## Result

The strict historical-topology replay completed on 2026-07-25.

- Run: `task7_historical_topology_8ep_20260725_080702`
- Submit user / Slurm job: `xiangqim` / `437141`
- Episodes: seeds `100` through `107`
- Stage success: `4/8 = 50.0%`
- Mean stage score: `75.0%`
- Goal success: `6/8 = 75.0%`
- Output root: `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task7_reference/task7_historical_topology_8ep_20260725_080702`
- Official summary: `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task7_reference/task7_historical_topology_8ep_20260725_080702/summary.tsv`
- Videos: `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task7_reference/task7_historical_topology_8ep_20260725_080702/videos/task7`

| Seed | Historical | Replay | Replay stage score |
| ---: | --- | --- | ---: |
| 100 | success | success | 100.0 |
| 101 | success | success | 100.0 |
| 102 | failure | failure | 33.3 |
| 103 | failure | failure | 66.7 |
| 104 | failure | failure | 66.7 |
| 105 | success | success | 100.0 |
| 106 | success | success | 100.0 |
| 107 | failure | failure | 33.3 |

The replay matches the historical success/failure outcome for every seed. This
is the valid direct comparison for the old `4/8` result. It does not make the
separate single-GPU 20-episode compatibility run valid or comparable.

## Fixed Inputs

- Remote source: `OpenHelix-Team/RoboMemArena@d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- Official scorer SHA256: `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`
- VLA checkpoint: `/data/user/hlei573/openpi/checkpoints/pi05_libero_robomemarena_fullvlm_v2_noflip_dataset/fullvlm_v2_robomemarena_noflip_v2_bs128_4gpu_20260507_183338/35999`
- VLA config: `pi05_libero_robomemarena_fullvlm_v2_noflip_dataset`
- VLA norm SHA256: `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`
- VLM checkpoint: `/data/user/zzhang510/hlei573_borrow_outputs/counting_task7_evalpour1hardcase256aligned_vlm_2gpu_acdu_20260724_093053/vlm_eval_ready/checkpoint-500`
- VLM model SHA256: `983f860aa286e3dcf30b253373b5d25dff107e8f1ffdc2a59fdf75fcbbd32d55`

## Topology And Fidelity

- Visible GPUs: `0,1`
- VLA server: GPU `0`
- VLM/evaluator and MuJoCo EGL: GPU `1`
- `REPLAN_STEPS=5`, `POST_STAGE_STEPS=30`, `VLM_INTERVAL=25`
- `HOLD_AFTER_REQUIRED_STAGES=0`; no oracle prompt injection or stage prompt override.

The generated execution package is a byte-identical copy of the frozen Task7
runner, autonomous runner, and evaluator. The only added entry is the
read-only `source/RoboMemArena_d9f83ac` link required by the frozen evaluator.
The frozen and execution SHA256 values are equal:

| File | SHA256 |
| --- | --- |
| `run_task7_8ep.sh` | `119f679cee3e178079b016d7d44c5c96947c691d6668ded4b718a661ee1b26e2` |
| `scripts/run_autonomous_task.sh` | `b500f776a393acb3e8fd1a512adefa0c3ea7a2b0b870d94f6babbc61b3dbfdfc` |
| `evaluators/eval_counting_autonomous_guarded_d9f83ac.py` | `7bc2f527a9d8064521910f64e8cfe02ca8c3d45642479f78c33f92e0b7624fae` |

The output contains `reference_manifest.env`, `run_manifest.txt`,
`execution_pack/execution_pack_manifest.json`, all eight per-episode logs, and
the official summary. The implementation and invalid predecessor are described
in `runs/TASK7_HISTORICAL_TOPOLOGY_8EP.md`.
