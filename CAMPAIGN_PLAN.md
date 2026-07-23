# Microwave Reproduction Campaign

## Goal

Run isolated, reproducible microwave-task evaluations for Task20, Task21,
Task22, Task23, and Task24. The working target is at least about 10 stage-only
successes in 20 valid episodes for each task. Task23's existing v155 15/20
record is the reference to preserve and reproduce. Task14 is also retained in
this monorepo under the same immutable version and publication discipline.

## Common Rules

1. Pin the RoboMemArena scorer to an explicit remote commit and require
   `task2_26_reference_stage.py`; no fallback to the old scorer is allowed.
2. Count microwave success from required stages only. `Close_Microwave` is
   optional.
3. The VLM must emit prompts. `ORACLE_*` prompt injection and object-moving
   anchors are prohibited in reported runs.
4. EEF hold/release and robot-only release anchors are permitted only as timing
   assistance; they cannot write the next prompt.
5. Every candidate gets a copied evaluator/config snapshot, manifest, SHA256
   record, per-episode video index, and aggregate summary before it is reported.
6. New job outputs are created below the hlei `irpn` workspace, never only
   under a borrowed account's home directory.

## Parallel Lanes

| Lane | Task | Starting point | First gate |
| --- | --- | --- | --- |
| A | Task20 | v110, fixed seed106 result 8/20 | Freeze one controlled successor and run 20 valid episodes. |
| B | Task21 | v121 autonomous-success package | Reproduce first, then expand to 20 episodes. |
| C | Task22 | latest autonomous candidate | Establish exact required-stage policy, then run a 1-episode gate. |
| D | Task23 | v155 fixed-seed105 result 15/20 | Reproduce with frozen v155 before exploring other seeds. |
| E | Task24 | v131 autonomous-success package | Reproduce first, then expand to 20 episodes. |

## Acceptance and Publication

An episode is valid only if its local validation confirms the scorer commit,
norm fingerprint, VLM identifier, autonomous-prompt policy, no oracle flags,
and a rendered video. A lane publishes only code, config, manifest, aggregate
TSV/JSON, and checksums to its GitHub repository. Videos and debug frames stay
in the shared `irpn` artifact archive and are indexed from the manifest.

## Mandatory Git Lifecycle

Every test, including a failed smoke test, follows this immutable sequence:

1. Create a new version directory with copied evaluator/config files and a
   pre-run manifest. Commit and push it before submitting the job.
2. Run only from that frozen directory.
3. Add the result summary, episode index, artifact checksum, and failure note
   or success evidence. Commit and push the outcome.
4. Never rewrite an old test directory or amend a published result commit.

All new versions are committed to this monorepo. The original per-task
repositories are imported under `tasks/` with their histories preserved, but
they are historical sources rather than new publication destinations.
