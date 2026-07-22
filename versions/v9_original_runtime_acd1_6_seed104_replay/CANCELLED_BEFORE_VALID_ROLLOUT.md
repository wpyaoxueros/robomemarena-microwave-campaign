# v9 Cancellation Record

v9 was cancelled before any valid rollout result.

The historical node already had a process bound to port 8722. The v8 base
runtime did not reserve-check the port before its server launch, so v9 could
not establish an isolated policy server. The Slurm job was cancelled rather
than allowing an evaluator to connect to an unrelated endpoint.

No v9 CSR, TSR, video, or summary may be reported. v11 replaces the launcher
with an allocation-local free-port check while preserving the v8 runtime.
