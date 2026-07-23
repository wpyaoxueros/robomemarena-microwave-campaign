# Task23 v157 Terminal Record

## Status

**Invalid infrastructure attempt; zero valid episodes.**

The first serial `seed=105` episode aborted before it produced an Episode
summary.  The evaluator process exited with `Aborted (core dumped)` after the
VLM loaded and before rollout progress began.  The fail-fast serial launcher
therefore did not start repeats 1--19.

This result must not be counted as either a Task23 success or a Task23 model
failure.

## Frozen Contract

- Parent pre-run commit: `9da6466`.
- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- Intended episodes: twenty independent `seed=105` one-episode rollouts.
- Actual episodes with an evaluator summary: `0/20`.
- Oracle prompt injection: disabled.
- Object-moving anchors: disabled.
- Submission: job `428591` on `ACD1-1`; scheduling-only change from v156.

## Evidence Hashes

Raw artifacts remain outside Git.  Their SHA256 values at terminal collection
time are:

| Artifact | SHA256 |
| --- | --- |
| repeat0 worker log | `e8d0b45f85a240d868490e810acb6c636cc02d8d6de8f8154bee4eedbbb86359` |
| repeat0 empty summary TSV | `b440d49be26e7469e50ffb98b24d7970705982159d0113e7db979741a064d66f` |
| serial launcher | `9c70e20aa9ceb5a98ceb00994ff481b043a56e5b1dfe31e50e665e5fd7c9bbb1` |
| Slurm submitter | `e2e6d9d407b970012bb461b4e51140e10d94d996387cee36ff6c4d516edce4eb` |

## Follow-up

Do not change rollout logic based on this attempt.  Re-run only after
isolating the CUDA/core-dump source with a fresh same-shell one-episode smoke.
