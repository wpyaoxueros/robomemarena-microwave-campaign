# Task22 v7: Historical-Node Legacy Replay

This is a single-variable follow-up to v6.

- Parent runtime: `../v6_legacy_b175708_seed104_replay`.
- Frozen evaluator, task configuration, BDDL, VLM input, VLA input, norm
  repository, seed, and rollout settings are inherited without modification.
- The only intentional change is the Slurm node: `ACD1-6`, which the
  historical policy-server log recorded for the six-stage rollout.
- The watcher first runs a fresh 1-GPU probe and a fresh 2-GPU probe on that
  node in the same shell. It starts the formal replay only after both pass.
- Output is ignored by Git; the resulting summary, video, and hashes must be
  recorded in a committed result document after the run.

This remains a legacy `b175708` scorer replay, not a current remote-scorer
result. No oracle prompt injection is permitted.
