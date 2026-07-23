# RoboMemArena Task22 Autonomous Reproduction

This repository contains a self-contained, path-sanitized Task22 evaluation
package. It pins the official stage scorer to
`62214036103ee8d5fef9b475dd8b344b6e2cfc03` and fails instead of falling back
to the older microwave evaluator.

The VLA/VLM checkpoint paths, training data, videos, and private environment
file are intentionally excluded. Supply them through an untracked environment
file based on `paths.example.env`.

The baseline entry point uses VLM-generated prompts and pure EEF hold/release.
All `ORACLE_*` variables are fixed to `0`; no object-moving anchor or
object-region/lift/gripper gate is enabled. `Close_Microwave` is audit-only;
the pinned stage scorer determines required-stage success.

Every new test must first add and push a `versions/<version>/PRE_RUN.md`. Raw
artifacts remain outside Git; the final result commit contains sanitized
metrics, code hashes, and artifact checksums.
