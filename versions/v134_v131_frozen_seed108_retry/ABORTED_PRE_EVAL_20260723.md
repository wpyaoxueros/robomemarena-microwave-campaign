# Aborted Pre-Evaluation Startup

- Scope: Task24 v131 frozen retry, seed 108.
- This startup was stopped before a valid episode result was produced.
- The run reached planner timestep 10 only; it has no official task summary or
  usable success/failure metric.
- Reason: the mutable source checkpoint now contained a norm asset that was
  absent when v131 originally ran. The server therefore selected a different
  norm-source branch from the recorded v131 log.
- Follow-up: the retry launcher now uses an isolated link tree with the same
  parameter files and no checkpoint `assets/` directory, restoring the
  recorded v131 norm fallback path without mutating the original checkpoint.
