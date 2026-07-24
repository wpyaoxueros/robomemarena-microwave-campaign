# zzhang510 Archived Batch Submission

The first exact20 batch contains Tasks `1, 3, 12, 13, 18, 25, 26`.

`scripts/launch_archived_batch_zzhang510.sh` is deliberately executed in one
`zzhang510` tmux shell. Before it launches a formal task, that same shell runs
a one-GPU account/compute write probe and a two-GPU formal-shape probe. It
tries partitions in this order: `acd_u`, `acd_ue`, then `emergency_acd`.

Every formal task receives two GPUs, a unique Slurm job name, a unique tmux
session and a unique VLA websocket port. The private runtime environment paths
are outside Git; the external run output records the actual submitted user,
partition, job id, command, copied rollout wrapper, source scorer and BDDL.
