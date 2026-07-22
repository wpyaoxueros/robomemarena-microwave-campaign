# Task22 v10: Queued Historical-Node Replay

v10 reuses the v8 original runtime without any evaluator, model-input, prompt,
or scoring change. It replaces v9's repeated immediate probes with one queued
two-GPU request on `ACD1-6`.

Once Slurm grants that allocation, the worker records a one-GPU visibility
check and a two-GPU visibility check in the same `zzhang510` shell before it
runs the v8 replay. This avoids losing a short two-GPU availability window
between a successful probe and the formal allocation.

No oracle prompt injection is used. This remains a legacy-scorer reproduction.
