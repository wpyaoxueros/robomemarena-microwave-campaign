# Invalid Worker Audit: GPU OOM

- Version: `v132_v131_multiseed20_five_nodes`
- Git revision at launch: `d904ae2978a6979ac76db8453f7bfabbe832477c`
- Slurm job: `429383`
- Worker: `0`
- Seeds: `104`, `105`, `106`, `107`
- Outcome: all four attempts are invalid and excluded from the 20-episode result.

The worker reached the real VLA/VLM evaluation path, but the VLM process failed while
allocating CUDA memory. The error occurred before an episode could emit an official
stage summary. This is a node/GPU allocation failure, not a task-stage failure.

No VLA checkpoint, policy path, dataset path, or scoring behavior changed for this
attempt. The replacement run must use the identical frozen runtime and a clean GPU
allocation, then record its own immutable result note.
