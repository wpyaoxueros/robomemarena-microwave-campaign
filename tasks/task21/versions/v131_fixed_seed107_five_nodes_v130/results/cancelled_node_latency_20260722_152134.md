# V131 Batch Cancellation: Node-Level Rollout Latency

The V131 five-node allocation was cancelled before a completed episode was
accepted. It correctly allocated one worker per physical node:
`ACD1-3`, `ACD1-4`, `ACD1-38`, `ACD1-39`, and `ACD1-40`.

The first three nodes executed VLA chunks at roughly 0.8 seconds per five
actions, matching the historical V127 condition. `ACD1-39` and `ACD1-40`
instead sustained roughly 20 seconds per five actions under the same code,
seed, scorer, and inputs. That node-level performance difference would prevent
the four repeat rollouts from completing within the two-hour allocation.

V132 preserves all rollout behavior and excludes only the two measured slow
nodes. No score from the cancelled V131 batch is reported or aggregated.
