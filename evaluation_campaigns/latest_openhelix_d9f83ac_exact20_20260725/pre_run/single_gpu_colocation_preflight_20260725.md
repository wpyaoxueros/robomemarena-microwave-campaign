# Single-GPU VLM + VLA preflight

## Purpose

Verify whether one Slurm GPU can host both the archived VLA policy server and
the VLM evaluator without changing the model, prompt logic, rollout logic, or
remote scorer. This is a compatibility check only, not a formal 20-episode
result.

## Invariants

- VLA remains the archived original `35999` policy and its checked norm hash.
- VLM checkpoint, task-specific flags, and rollout body come only from the
  private archived task environment.
- The evaluator is the d9 callback adapter over remote
  `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`.
- Exactly one GPU is visible. The generic runner must log the same allocated
  Slurm GPU value for both processes, for example `GPU binding: VLA=4 VLM=4`.
- The preflight has exactly one episode. It is excluded from all formal
  20-episode aggregation.
- The submit account needs only targeted traversal/read access to the existing
  norm asset; the preflight verifies its SHA before the server starts.

## Pass condition

The VLA server reaches its port, the VLM evaluator starts on the same GPU, and
the generated artifact contains the one-GPU binding and one episode summary.
An OOM, early server exit, permission error, or missing current scorer is a
hard failure and blocks one-GPU formal workers.
