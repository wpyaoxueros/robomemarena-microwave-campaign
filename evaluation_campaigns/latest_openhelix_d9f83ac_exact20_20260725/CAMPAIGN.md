# Latest OpenHelix Exact20 Campaign

This is the Git-tracked pre-run record for the 2026-07-25 re-evaluation campaign.

## Official evaluator

- Repository: `https://github.com/OpenHelix-Team/RoboMemArena`
- Branch: `main`
- Frozen remote commit: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- Fetch verification: `git ls-remote` returned the same commit on 2026-07-25.
- Snapshot: [`source_snapshot`](source_snapshot), generated directly by `git archive` from that commit.
- Required stage scorer: `evaluation_benchmark/scripts/task2_26_reference_stage.py`
- Required scorer SHA256: `0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`

This campaign must fail before rollout if the scorer file is absent or its hash differs. It must not fall back to the older `eval_tasks2_26.py` stage logic.

## Scope

- Included: `1, 3, 6, 7, 10, 12, 13, 14, 16, 18, 20, 21, 22, 23, 24, 25, 26`.
- Excluded: `2`, by explicit user direction.
- Episodes: `20` valid episodes per included task.
- VLA: original fullvlm-v2 noflip `35999` and its matched norm, not later fine-tuned VLA checkpoints.

## Result rules

- Task1/3/12/13/14/18/25/26: retain the frozen rollout behavior and calculate the final metrics with the frozen current official source.
- Task6/7/10/16: use remote `stage_success` as the primary counting result. `goal_success` is audit-only.
- Task20--24: use remote mandatory-stage completion as primary. `Close_Microwave` is audit-only. `goal_success` is recorded but not used to replace a stage result.
- Microwave prompt source must remain VLM-led: no `ORACLE_*` next-prompt injection and no object-moving anchor may be reported as autonomous success.

## Reproducibility contract

Every task result must contain a run manifest with the exact launch command, VLA/VLM identifiers, norm SHA256, remote commit, scorer SHA256, copied launcher/evaluator, official summaries, and raw artifact paths/checksums. The pre-run record is committed before GPU submission; result records are committed after completion.
