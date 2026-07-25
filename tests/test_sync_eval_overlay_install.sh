#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEMP_ROOT}"' EXIT

mkdir -p "${TEMP_ROOT}/reference_evaluation"
"${ROOT}/sync_eval_overlay/install_into_sync_eval.sh" "${TEMP_ROOT}/reference_evaluation" >/dev/null
DEST="${TEMP_ROOT}/reference_evaluation/tasks2_26_vlm5_reference"

for file in \
  eval_tasks2_26_vlm_vla.py \
  eval_tasks2_26_vlm_vla_base.py \
  fullvlm_v2_26_memory_tasks.json \
  run_tasks2_26_vlm_vla_csr_tsr.sh \
  serve_policy_custom_repo.py \
  tasks2_26_endpose_targets_seed100_199.json; do
  test -f "${DEST}/${file}"
done
bash -n "${DEST}/run_tasks2_26_vlm_vla_csr_tsr.sh"
python3 -m py_compile "${DEST}/eval_tasks2_26_vlm_vla.py"
echo 'PASS sync-eval overlay installation'
