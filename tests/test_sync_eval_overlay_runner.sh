#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERLAY="${ROOT}/sync_eval_overlay/tasks2_26_vlm5_reference"
RUNNER="${OVERLAY}/run_tasks2_26_vlm_vla_csr_tsr.sh"

bash -n "${RUNNER}"
grep -F 'VLA_CKPT:?Set VLA_CKPT' "${RUNNER}"
grep -F 'VLM_CKPT:?Set VLM_CKPT' "${RUNNER}"
grep -F 'TASKS2_26_BASE_EVAL_PY="${SCRIPT_DIR}/eval_tasks2_26_vlm_vla_base.py"' "${RUNNER}"
grep -F 'ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR' "${RUNNER}"
grep -F 'serve_policy_custom_repo.py' "${RUNNER}"
if grep -Fq '/task123_exact/' "${RUNNER}"; then
  echo 'external task123 path leaked into overlay runner' >&2
  exit 1
fi
echo 'PASS sync-eval microwave overlay runner contract'
