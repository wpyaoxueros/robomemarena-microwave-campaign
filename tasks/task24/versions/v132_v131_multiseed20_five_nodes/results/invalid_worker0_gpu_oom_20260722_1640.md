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

## Root-cause evidence

The runtime's binding was correct: the policy server was launched with visible GPU
`0` and the VLM evaluator with visible GPU `1`. A same-allocation inspection of
`ACD1-1` found both physical GPUs already consuming about `64 GiB / 80 GiB` before
the VLM could load. The occupying processes were orphaned (`PPID=1`) and did not
belong to this evaluation job. Therefore the CUDA error's reported `GPU 0` is the
VLM process's remapped visible device, not evidence that VLA and VLM were placed on
the same physical GPU.

The retry must exclude `ACD1-1`; it must not change the frozen evaluation runtime.

No VLA checkpoint, policy path, dataset path, or scoring behavior changed for this
attempt. The replacement run must use the identical frozen runtime and a clean GPU
allocation, then record its own immutable result note.
