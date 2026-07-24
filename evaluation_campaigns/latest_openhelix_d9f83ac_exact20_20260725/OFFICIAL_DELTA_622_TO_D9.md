# Official Delta: 6221403 to d9f83ac

This comparison was made directly from `OpenHelix-Team/RoboMemArena` after a fresh fetch on 2026-07-25.

| Item | `6221403` | `d9f83ac` | Result |
| --- | --- | --- | --- |
| `task2_26_reference_stage.py` SHA256 | `0ab5e19...` | `0ab5e19...` | byte-identical |
| Task20 BDDL SHA256 | `8324d68...` | `8324d68...` | byte-identical |
| Task21 BDDL SHA256 | `4d5956b...` | `4d5956b...` | byte-identical |
| Task22 BDDL SHA256 | `dbfadff...` | `dbfadff...` | byte-identical |
| Task23 BDDL SHA256 | `8f92b31...` | `8f92b31...` | byte-identical |
| Task24 BDDL SHA256 | `3749a37...` | `3749a37...` | byte-identical |

The only source-code change under `evaluation_benchmark` in that interval is the default seed range in `scripts/run_all_tasks1_26.py`; it does not alter the stage scorer, BDDL, reference evaluator, or OpenPI minimal runtime. Therefore a frozen `6221403` microwave rollout may be evaluated against the `d9f83ac` checkout without changing its rollout logic, provided the launcher explicitly records the new commit and validates the scorer hash.
