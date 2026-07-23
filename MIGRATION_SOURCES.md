# Monorepo Migration Sources

The following frozen repositories were imported without `--squash`; their
original commits remain reachable from this monorepo history. No source
repository was deleted or rewritten.

| Monorepo path | Original repository | Imported tip |
| --- | --- | --- |
| `tasks/task20` | `robomemarena-task20-v49c6-repro` | `3439d37bbbd76ceaf8bdc785e74305ce797be910` |
| `tasks/task21` | `robomemarena-task21-v121-repro` | `0ed2d9ac838831d6a9a7dc8d2027bac369d77bdc` |
| `tasks/task22` | `robomemarena-task22-autonomous-repro` | `561b34d126fad43d8ba2587c37ebc2eab3952de2` |
| `tasks/task24` | `robomemarena-task24-v123-autonomous-repro` | `4dc1dc932a3f24d743714d8c1a71fb8955cb18d1` |
| `tasks/task23/v145_eef_anchor` | `robomemarena-task23-v145-eef-anchor-repro` | `12c589b443a1908b37a0f9177ecc3c84dea1e112` |
| `tasks/task23/v146_placepopcorn_hold1` | `robomemarena-task23-v146-placepopcorn-hold1-repro` | `a7f7a8a5cecddf2a53d2f3a7d644ddd589304858` |
| `tasks/task23/v147_selfcontained_norm` | `robomemarena-task23-v147-selfcontained-norm-repro` | `b342c5c67a5001152a190e356d797ed9549a18b3` |
| `tasks/task23/v148_snapshotfix` | `robomemarena-task23-v148-snapshotfix-repro` | `1c7295ddd02feb34ee05ed4d8db78b9845495e10` |
| `tasks/task23/v149_trainingprompt` | `robomemarena-task23-v149-trainingprompt-repro` | `f9b9ae7419bd03bda9a9727acf553697c8d2fcba` |
| `tasks/task23/v150_no_placepopcorn_hold` | `robomemarena-task23-v150-no-placepopcorn-hold-repro` | `7ffe480f36aa3ca65cc45c1795e55d7fa011cffc` |
| `tasks/task23/v155_fixedseed105_repeat20` | `robomemarena-task23-v155-fixedseed105-repeat20` | `521c67da220eebb8f281ff9de075aff7d6315017` |

Task22 has an uncommitted local v23 draft in the old source checkout. It is
intentionally excluded until it has a pre-run record and a source commit.
