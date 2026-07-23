# Task22 v13: Historical Input-Locked Legacy Replay

This version retries the July historical Task22 seed104 run without changing
the frozen v8 evaluator, policy server, BDDL, rollout settings, or prompt
logic. It only fixes a reproducibility defect: the shared ignored `inputs.env`
was later changed to a different VLA checkpoint and norm repository.

## Fixed Contract

- Reuse `../v8_legacy_original_runtime_seed104_replay/runtime` byte-for-byte.
- Task22, seed104, one episode, 2000 max steps, replan interval 10.
- Async VLM interval 5, queue size 1, five recent frames, wrist and keyframe
  memory enabled.
- No oracle next-prompt injection and no historical prompt replay.
- Run on `ACD1-6`, the node recorded by the historical policy-server log.
- Require a private ignored `inputs.env` whose path and artifact fingerprints
  match the historical July launcher before any GPU work begins.

This is a legacy-runtime reproduction only. It is not a score under the
current remote evaluator.
