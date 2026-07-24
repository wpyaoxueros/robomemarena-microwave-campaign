# Task18 original snapshot topology replay

This is a controlled replay of `v1_original_snapshot_replay`.

## What is identical to v1

- historical evaluator and launcher source hashes
- historical Task18 parameters, VLM checkpoint interface, VLA policy interface,
  norm selection, target JSON and passage JSON
- no modern campaign adapter and no current remote scorer injection

## Only controlled runtime change

The Slurm allocation is pinned to the historical rollout node family and uses
the historical distribution mode:

```text
--nodelist=ACD1-11
--distribution=cyclic,pack
```

This version exists because the first v1 replay used the historical source but
ran about 25x slower after the initial JAX compile on a different node and CPU
binding. It is an execution-topology comparison, not a semantic evaluator
change. The local run manifest records the resolved Slurm node, GPU ids and
CPU binding.

Model locations are supplied through local environment variables only and are
recorded in [LOCAL_RUNTIME_MANIFEST.md](LOCAL_RUNTIME_MANIFEST.md) so this
version remains fully recoverable.
