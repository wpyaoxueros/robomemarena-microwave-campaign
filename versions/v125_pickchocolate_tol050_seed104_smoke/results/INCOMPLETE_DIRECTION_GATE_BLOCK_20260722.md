# Task21 v125 Incomplete Diagnostic Record

## Status

This is not a complete episode and does not score the `pick chocolate=0.050m`
tolerance change. The rollout was deliberately stopped after the intended
boundary became unreachable.

- Parent pre-run code commit: `8bb9390`.
- Slurm job: `428584` on `ACD1-22`, cancelled after 14m24s.
- Official scorer: `62214036103ee8d5fef9b475dd8b344b6e2cfc03`.
- All `ORACLE_*` controls were zero; VLM generated the prompt stream.
- The rollout completed `01_Open_Microwave` and reached the EEF-only
  `open microwave` hold before release.

## Observed Boundary

At timestep 200 onward, VLM repeatedly emitted `place butter`, but the active
prompt remained `pick butter` because the pick-forward hold/release guard
required a valid directional approach. The EEF was already close to the pick
target (`0.01136m` versus `0.03000m` tolerance), but the direction diagnostic
was `low_displacement` with displacement below `0.0001m`. The next-prompt
handoff was therefore blocked before the rollout could reach `pick chocolate`.

This is a guard-boundary diagnostic, not oracle prompt injection and not a
model conclusion. A successor must separately decide whether the frozen
direction requirement should be adapted; it must not claim v125 as a result
for the changed pick-chocolate tolerance.

## External Artifact Checksums

```text
sync_vlm.log                 1cd5d93673ec79376ce97f7743af5bf6287658fc0236cf6263845e2322c85543
submit.log                   b025c17ebbd95d050e956332fa7cff650af3e1df1385ba07372936f9d5397574
PRE_RUN.md                   d7f36b3bff93f9e68d97594fcd1597cc9e24701a795631d4e3632924b89bff36
snapshot artifact SHA table  cec170d8211b47a16ed471ff4e42b8ff3545148e584d8146c61d305799d87344
```

Raw logs, frames, manifests, and the frozen runtime snapshot are retained
under the shared campaign artifact root for
`task21_v125_pickchocolate_tol050_seed104_20260722_081546`.
