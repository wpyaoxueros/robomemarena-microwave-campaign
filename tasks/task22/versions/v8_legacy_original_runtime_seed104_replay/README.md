# Task22 v8: Original Runtime Seed104 Replay

## Purpose

Reproduce the historical Task22 seed104 six-stage legacy result using the
actual runtime directory referenced by the original July launcher.

## What Is Frozen

- Task22, seed 104, one episode, 2000 maximum steps, replan interval 10.
- Async VLM interval 5, one-slot queue, five recent frames, wrist image and
  keyframe memory enabled.
- The original legacy evaluator and its entire `openpi_minimal_runtime`, not
  a later upstream commit with revised microwave or container checks.
- The original Task22 BDDL and the policy-server source used by the launcher.
- No oracle next-prompt injection is present. The VLM continues to supply the
  current primitive prompt.

## Why v8 Exists

v6 froze a byte-identical evaluator entrypoint but accidentally paired it with
later helper modules. Those helpers changed the microwave joint/fallback logic
and the container z window. v8 freezes the actual original helper runtime,
which is required for a valid historical reproduction.

This is a legacy-evaluator replay. It must not be reported as a result under
the current remote scorer.
