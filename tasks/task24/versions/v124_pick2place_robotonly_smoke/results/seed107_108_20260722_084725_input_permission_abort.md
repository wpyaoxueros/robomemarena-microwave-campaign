# Task24 v124 Pre-rollout Permission Abort

## Scope

- Seeds: `107`, `108`
- Attempt timestamp: `20260722_084725`
- Source commits: `33557ff`, `35316e7`
- Official scorer requested: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`

## Outcome

Both Slurm allocations started, but each launcher exited before loading VLA or
VLM and before environment rollout. No video, stage score, goal score, or
prompt trace exists for either seed.

## Root Cause

The ignored private input file had group `irpn` but mode `0600`. The borrowed
`zzhang510` account belongs to `irpn`, yet could not read the file. The
correct private-file mode is group-readable `0640` while keeping the file out
of Git.

## Corrective Boundary

This record does not change v124 evaluation logic. The only runtime correction
is private-file access. The next launch must use the same source commit plus a
readability preflight and must receive a distinct output timestamp.
