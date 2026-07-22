# Invalid Pre-Evaluation Attempt

Slurm job `430911` is excluded from behavior metrics. It passed both resource
probes but exited before starting the VLA server or evaluator.

Root cause: `verify_snapshot.sh` searched for literal tab bytes in the frozen
Python source, while the source intentionally contains the escaped `\\t` text
inside its Python string literal. The source hashes all passed. The verification
pattern is corrected to check the escaped source text; no evaluator, model,
seed, norm, prompt, or rollout setting changed.
