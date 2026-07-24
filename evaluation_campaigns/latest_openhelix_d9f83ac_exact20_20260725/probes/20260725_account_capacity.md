# 2026-07-25 Account Capacity Probe

No formal rollout started during this probe sequence.

| Submit user | Probe job | Partition | Result | Action |
| --- | --- | --- | --- | --- |
| `zzhang510` | `436715` | `acd_u` | immediate allocation rejected: busy | no rollout submitted |
| `zzhang510` | `436716` | `acd_ue` | `QOSMaxGRESPerUser` | cancelled only this pending probe |
| `prtroas0003` | `436718` | `acd_u` | immediate allocation rejected: busy | no rollout submitted |
| `prtroas0003` | `436720` | `acd_ue` | `QOSMaxGRESPerUser` | cancelled only this pending probe |

The pre-existing jobs under both accounts were left unchanged. The three named
borrowed accounts each had active jobs at probe time, so a new formal two-GPU
evaluation cannot be launched until one of their GPU quotas is released. The
pre-run contracts remain valid and can be re-submitted without changing any
rollout or scoring code.
