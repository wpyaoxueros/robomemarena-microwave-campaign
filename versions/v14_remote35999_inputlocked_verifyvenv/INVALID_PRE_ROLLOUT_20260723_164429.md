# Invalid Pre-Rollout: 2026-07-23 16:44:29

The requested one-episode Task22 v14 job received a two-GPU allocation, then
exited before the VLA server or evaluator started. No rollout, video, stage
score, or success metric was produced.

Root cause: the submit command received a relative private-input path. The
launcher changed into the version directory before invoking `run_1ep.sh`, so
the same relative path was resolved a second time and became unreadable.

Fix: canonicalize the private-input path with `readlink -f` in submit, launcher,
and runtime entrypoints. The corrected version must pass the no-GPU preflight
before any replacement rollout is launched.
