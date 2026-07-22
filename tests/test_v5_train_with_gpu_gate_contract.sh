#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v5_native_boundary_gpu_gate_20260722"

for file in "${VERSION}/PRE_TRAIN.md" "${VERSION}/run_train.sh" "${VERSION}/probe_one_batch.sh" "${VERSION}/dispatch_train_after_probe_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION}/run_train.sh" "${VERSION}/probe_one_batch.sh" "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -F -q 'v4_device_binding_preflight_20260722' "${VERSION}/run_train.sh"
rg -F -q 'collect_gpu_preflight.py' "${VERSION}/run_train.sh"
rg -F -q 'probe_gpu_binding.py' "${VERSION}/run_train.sh"
rg -F -q -- '--require-clean' "${VERSION}/run_train.sh"
rg -F -q 'run_probe 4' "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -F -q 'run_probe 2' "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -F -q -- '--freeze_vision_tower' "${VERSION}/run_train.sh"
rg -F -q -- '--predictive_coding_head' "${VERSION}/run_train.sh"
! rg -q 'ORACLE_' "${VERSION}"
echo 'task22 v5 GPU-gated train contract: PASS'
