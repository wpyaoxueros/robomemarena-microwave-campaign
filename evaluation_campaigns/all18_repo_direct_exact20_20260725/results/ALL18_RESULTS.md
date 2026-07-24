# All-18 Reproduction Results

This table is updated only from a completed task's official summaries and
run manifest. A historical result is not counted as a new campaign result.

| Task | Frozen package | Episodes | Success | Scorer | Status | Result manifest |
| --- | --- | ---: | ---: | --- | --- | --- |
| 1 | archived direct-use package | 0/20 | - | d9f83ac | invalid: 20 trace dirs but official aggregate says num_trials=0 | `runs/ARCHIVED_DIRECT20_SINGLE_GPU_20260725.md` |
| 2 | archived special package | 0/20 | - | original frozen Task2 route | invalid startup, no official episode; relaunch required | `/data/user/xiangqim/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725/task2/task2_all18_frozen20_single_gpu_20260725_061059/` |
| 3 | archived direct-use package | 0/20 | - | d9f83ac | invalid: evaluator core dumped before first official summary | `runs/ARCHIVED_DIRECT20_SINGLE_GPU_20260725.md` |
| 6 | Task6 counting package | 0/20 | - | d9f83ac | running after source-overlay fix | `runs/COUNTING_DIRECT20_OVERLAYFIX_20260725.md` |
| 7 | Task7 counting package | 20/20 single-GPU compatibility | stage 20.0% | d9f83ac | excluded from strict historical comparison: VLA/VLM/MuJoCo were colocated on one GPU; rerun seeds100--107 through the frozen two-GPU topology first | `runs/TASK7_HISTORICAL_TOPOLOGY_8EP.md` |
| 10 | Task10 counting package | 0/20 | - | d9f83ac | current frozen-package run active; counts when 20 valid summaries exist | `runs/COUNTING_DIRECT20_OVERLAYFIX_20260725.md` |
| 12 | d9 archived continuation | 20/20 | stage 50.0%, goal 70.0% | d9f83ac | complete, counted | `/data/user/xiangqim/hlei573_borrow_outputs/latest_openhelix_d9f83ac_exact20_20260725/task12/task12_openhelix_d9f83ac_exact20_seed104_20260725_030249/logs_task_sync_hold/task12_openhelix_d9f83ac_exact20_seed104_20260725_030249/summary.tsv` |
| 13 | d9 archived continuation | 20/20 | stage 70.0%, goal 76.7% | d9f83ac | complete, counted | `/data/user/xiangqim/hlei573_borrow_outputs/latest_openhelix_d9f83ac_exact20_20260725/task13/task13_openhelix_d9f83ac_exact20_seed104_20260725_030249/logs_task_sync_hold/task13_openhelix_d9f83ac_exact20_seed104_20260725_030249/summary.tsv` |
| 14 | Task14 v1 | 0/20 | - | pending | pending | - |
| 16 | Task16 counting package | 0/20 | - | d9f83ac | current frozen-package run active; counts when 20 valid summaries exist | `runs/COUNTING_DIRECT20_OVERLAYFIX_20260725.md` |
| 18 | Task18 v2 original snapshot | 0/20 | - | d9 overlay pending | fresh required | current v3/archived worker excluded |
| 20 | Task20 v110 | 0/20 | - | d9 overlay ready | blocked: the two frozen robot-anchor HDF assets are missing; long-HDF substitution is prohibited | `LOCAL_ASSET_REGISTRY.md` |
| 21 | Task21 v121 | 0/20 | - | d9 overlay ready | fresh direct-use 20ep launcher ready | `runs/TASK21_D9_DIRECT20_SINGLE_GPU.md` |
| 22 | Task22 autonomous package | 0/20 | - | d9f83ac | fresh required | - |
| 23 | Task23 v155 | 0/20 | - | d9 overlay pending | fresh required | - |
| 24 | Task24 v131 | 0/20 | - | d9 overlay pending | fresh required | - |
| 25 | archived direct-use package | 0/20 | - | d9f83ac | invalid: WebSocket endpoint returned HTTP 200 before first official summary | `runs/ARCHIVED_DIRECT20_SINGLE_GPU_20260725.md` |
| 26 | archived direct-use package | 0/20 | - | d9f83ac | current frozen-package run active; counts when 20 valid summaries exist | `runs/ARCHIVED_DIRECT20_SINGLE_GPU_20260725.md` |
