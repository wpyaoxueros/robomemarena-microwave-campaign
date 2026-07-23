#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

RUN_GROUP=test_task6_fixed_seed
WORKER_ID=0
REPEAT_START=0
REPEAT_COUNT=2
FIXED_SEED=100
VLM_CKPT=/tmp/fake-vlm
RUNS_BASE="${TMP}/runs"
LOG_DIR="${TMP}/logs"
RUNNER="${ROOT}/tests/fixtures/fake_autonomous_runner.sh"

export RUN_GROUP WORKER_ID REPEAT_START REPEAT_COUNT FIXED_SEED VLM_CKPT RUNS_BASE LOG_DIR RUNNER
bash "${ROOT}/scripts/run_task6_fixed_seed_repeat_worker.sh"

[[ "$(wc -l < "${RUNS_BASE}/repeat_results.tsv")" == "3" ]]
grep -q $'0\t0\t100\t0\t100.0\t1.0000\t1.0000' "${RUNS_BASE}/repeat_results.tsv"
grep -q $'0\t1\t100\t0\t100.0\t1.0000\t1.0000' "${RUNS_BASE}/repeat_results.tsv"
python - "${RUNS_BASE}/worker_summary.json" <<'PY'
import json
import sys

payload = json.load(open(sys.argv[1], encoding="utf-8"))
assert payload["episodes"] == 2
assert payload["stage_successes"] == 2
assert payload["stage_success_rate"] == 1.0
PY
