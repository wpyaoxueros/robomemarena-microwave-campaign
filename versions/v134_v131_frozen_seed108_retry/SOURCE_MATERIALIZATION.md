# v131 Source Materialization

This runtime was copied from the historical v131 frozen `code_snapshot`.

Byte-identical runtime files:

- `scripts/run_task24_v130_pickpopcorn_tol007_keepdirection_latest622_1ep.sh`
- `scripts/run_task24_v123_strict_adjacent_latest622_1ep.sh`
- `scripts/serve_policy_custom_repo.py`

The other copied launch files have only these non-behavioral changes:

1. historical hard-coded private paths became required private environment variables;
2. anchor HDF paths expand from `ROBOMEMARENA_FULLVLM_DATA_ROOT`;
3. the old hard-coded relative launcher now resolves within this copied runtime;
4. unused builder scripts were omitted from the public package, and snapshot copying is conditional;
5. the original HDF5 utility path is now required from private inputs.

The supplied values are checked before rollout. The hold/release configuration, target JSON content, anchor frames, VLM prompt mode, VLA settings, scorer commit, task seed, and oracle flags are unchanged.

`SOURCE_SHA256.tsv` records every chain file before and after materialization.
