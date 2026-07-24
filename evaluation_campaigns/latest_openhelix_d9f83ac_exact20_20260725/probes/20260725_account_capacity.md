# 2026-07-25 Account Capacity Probe

No formal rollout started during this probe sequence.

| Submit user | Probe job | Partition | Result | Action |
| --- | --- | --- | --- | --- |
| `zzhang510` | `436715` | `acd_u` | immediate allocation rejected: busy | no rollout submitted |
| `zzhang510` | `436716` | `acd_ue` | `QOSMaxGRESPerUser` | cancelled only this pending probe |
| `prtroas0003` | `436718` | `acd_u` | immediate allocation rejected: busy | no rollout submitted |
| `prtroas0003` | `436720` | `acd_ue` | `QOSMaxGRESPerUser` | cancelled only this pending probe |
| `prtroas0003` | `436734` | `acd_u` | immediate allocation rejected: busy | no rollout submitted |
| `prtroas0003` | `436735` | `acd_ue` | immediate allocation rejected: busy | no rollout submitted |
| `prtroas0003` | `436737` | `emergency_acd` | immediate allocation rejected: busy | no rollout submitted |

The pre-existing jobs under both accounts were left unchanged. The three named
borrowed accounts each had active jobs at probe time, so a new formal two-GPU
evaluation cannot be launched until one of their GPU quotas is released. The
pre-run contracts remain valid and can be re-submitted without changing any
rollout or scoring code.

## 02:25 retry after capacity became available

The scheduler enforces a `240 GB/GPU` memory ceiling. A first direct request
with `--mem=2000G` was rejected by this scheduler rule before allocation; it
was not a filesystem or model error. The following no-account probes were then
performed from the `zzhang510` shell:

| Probe job | Partition | Shape | Result |
| --- | --- | --- | --- |
| `436761` | `acd_u` | 1 GPU, 240 GB | busy |
| `436762` | `acd_ue` | 1 GPU, 240 GB | busy |
| direct retry | `emergency_acd` | 1 GPU, 240 GB | PASS on `ACD1-20` |
| direct retry | `emergency_acd` | 2 GPU, 480 GB, 16 CPU | PASS on `ACD1-40` |
| direct retry | `emergency_acd` | 2 GPU, 480 GB, 16 CPU | PASS again on `ACD1-40` |

The formal Task1/Task3 submissions below therefore use the verified
`emergency_acd`, 2-GPU, 480-GB shape. They remain no-explicit-account jobs.

## `xiangqim` Task12 capacity and access check

`xiangqim` is a member of `irpn`. Before allocating GPUs, the account verified
read access to Task12's private runtime environment, frozen rollout scripts,
official scorer, original VLA35999 and matching norm, VLM checkpoint, and all
required runtime roots. Its own output root was created with group `irpn` and
setgid permissions.

| Partition | Shape | Result |
| --- | --- | --- |
| `emergency_acd` | 1 GPU, 240 GB | PASS on `ACD1-1` |
| `emergency_acd` | 2 GPU, 480 GB, 16 CPU | PASS on `ACD1-1` |

Task12 may therefore run as a no-explicit-account, two-GPU job from this
account without changing rollout or scoring code.

## `xiangqim` five-GPU capacity check

After the two-GPU checks, a no-account five-GPU probe also passed on `acd_u`:

| Partition | Shape | Result |
| --- | --- | --- |
| `acd_u` | 5 GPU, 40 CPU, 1200 GB | PASS on `ACD1-26` |

Any formal batch launched from this allocation still keeps separate two-GPU
VLM+VLA workers; no idle GPU will be represented as a completed evaluation.

## Existing `prtroas0003` allocation check

The current `prtroas0003` allocation `434516` is an 8-GPU job on `ACD1-2`.
It was inspected without modifying it after the three probes above. All eight
GPUs were actively occupied (78%--100% utilization, about 74 GiB used per
GPU), so it cannot safely host an additional evaluation worker. No step was
started inside that allocation.
