# `xiangqim` one-GPU-per-task workers

Each formal archived evaluation receives one GPU and retains the original
VLA+VLM processes. The generic archived runner sees a single visible GPU and
therefore binds both processes to that exact Slurm GPU. No prompt logic,
rollout settings, VLA checkpoint, VLM checkpoint, norm, or scorer changes.

The initial Task12 colocation preflight completed real VLM generation and VLA
actions on one H100 80 GB GPU before this formal layout was introduced. It
showed a tight but nonzero memory margin, so each worker must remain alone on
its GPU with no auxiliary model process.

The launcher records the actual submit user, Slurm job, remote scorer commit,
task-to-GPU mapping, and per-task exit status in the private artifact root.
