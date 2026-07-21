# Task24 v123 Pre-Run Record

Run the frozen v123 autonomous evaluator on one episode each for seeds `107`
and `108`. These are independent smoke checks before any broader 20-episode
measurement.

Contract: official commit `62214036103ee8d5fef9b475dd8b344b6e2cfc03`,
`MAX_STEPS=2000`, `REPLAN_STEPS=5`, all `ORACLE_* = 0`, VLM-generated prompts,
EEF-only holds, and robot-only anchors. The run is invalid if it falls back to
an older official scorer or has a nonzero oracle flag.
