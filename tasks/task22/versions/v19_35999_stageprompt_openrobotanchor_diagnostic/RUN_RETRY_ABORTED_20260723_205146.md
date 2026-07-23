# Task22 v19 Alternate-Node Retry Aborted Before Anchor

- Started: `2026-07-23T20:51:46+08:00`
- Slurm job: `432849`
- Node: `ACD1-13`
- State: `FAILED`, exit `6:0` / SIGABRT (`rc=134`)
- Last completed rollout boundary: `t=500`, while executing scheduled `pour first`

## What Was Verified

- The allocation used two H100 80 GB GPUs and the VLM process was actively
  computing on its allocated GPU; it did not fall back to CPU.
- v19 reached the same first physical stage as v18: real lift-tomato success at
  `t=156`.
- The single `open microwave` robot-only anchor was still not reached, so this
  result cannot test or reject it.

## Interpretation

Moving off the overloaded `ACD1-61` did not remove the deterministic abort near
the fiftieth raw VLM generation. Since the stage-prompt diagnostic already
owns the VLA action prompt, raw VLM inference is observational at this point.
The next isolated diagnostic will preserve VLA replan at ten actions and all
physical stage checks, but refresh the raw VLM trace less often to test whether
the repeated VLM generation is the abort source.

This is not reported as a failed robot policy or an anchor failure.
