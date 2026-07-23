# Diagnostic Retry Started

The first formal launch passed both GPU probes but exited on `ACD1-11` before
creating an evaluator log. This retry keeps the same frozen runtime, seed,
model inputs, and rollout parameters, excludes only `ACD1-11`, and runs the
wrapper under `bash -x` to expose the failing setup command.

It is an infrastructure diagnostic. Its behavior result, if any, is recorded
separately and does not replace the clean replay result.
