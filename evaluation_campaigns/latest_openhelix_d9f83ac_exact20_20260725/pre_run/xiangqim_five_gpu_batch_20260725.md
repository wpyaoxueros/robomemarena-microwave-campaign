# `xiangqim` five-GPU evaluation batch

## Allocation layout

One `lhs_...` Slurm allocation reserves five GPUs. It runs two independent
formal archived reproductions and one isolated colocation compatibility check:

| Workload | GPUs | Episodes | Role |
| --- | --- | --- | --- |
| Task12 | first two | 20 | formal exact-20 evaluation |
| Task13 | next two | 20 | formal exact-20 evaluation |
| Task12 | final one | 1 | VLM+VLA one-GPU preflight |

## Guarantees

- The formal workers use the original 35999 VLA and their archived VLM runtime
  environments; those paths stay outside Git.
- Both formal workers use the current d9 callback adapter and the checked
  remote stage scorer.
- The single-GPU run is recorded separately and never aggregated into formal
  task results.
- The batch manifest records actual Unix user, Slurm job, GPU assignment,
  remote commit, and seeds in the private artifact root.

When the account has only three free GPUs, the same layout degrades without
changing any worker: Task12 retains its two-GPU formal worker and the final
GPU runs the isolated preflight. Task13 is not started until another two GPUs
are actually available.
