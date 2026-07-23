# Invalid Pre-Rollout: 2026-07-23 16:47:00

The replacement one-episode v14 job passed the `35999` input lock and the
Task22 stage-contract check, then exited before the VLA server or evaluator
started. No rollout, video, stage score, or success metric was produced.

Root cause: the shared launcher recognized a Git checkout only when `.git` was
a directory. The repaired RoboMemArena checkout is a Git worktree, where `.git`
is a file. Its commit was therefore reported as `unknown` despite the v14
preflight correctly verifying the repair commit.

Fix: resolve the revision using `git -C <remote-root> rev-parse HEAD`, which
works for both normal checkouts and worktrees, then fall back to a `COMMIT` file
only when Git cannot resolve a revision.
