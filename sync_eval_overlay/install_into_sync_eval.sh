#!/usr/bin/env bash
set -euo pipefail

# Install the overlay into an existing RoboMemArena
# evaluation_benchmark/reference_evaluation directory.
DEST_PARENT=${1:?usage: install_into_sync_eval.sh <reference_evaluation_dir>}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${SCRIPT_DIR}/tasks2_26_vlm5_reference"
DEST="${DEST_PARENT}/tasks2_26_vlm5_reference"

[[ -d "${DEST_PARENT}" ]] || { echo "missing reference_evaluation directory: ${DEST_PARENT}" >&2; exit 2; }
mkdir -p "${DEST}"
for file in \
  eval_tasks2_26_vlm_vla.py \
  eval_tasks2_26_vlm_vla_base.py \
  fullvlm_v2_26_memory_tasks.json \
  run_tasks2_26_vlm_vla_csr_tsr.sh \
  serve_policy_custom_repo.py \
  tasks2_26_endpose_targets_seed100_199.json; do
  install -m 0755 "${SOURCE}/${file}" "${DEST}/${file}"
done
echo "installed_overlay=${DEST}"
