#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v3_native_pour_boundary_upweight"

for file in "${VERSION}/PRE_TRAIN.md" "${VERSION}/run_train.sh" "${VERSION}/probe_one_batch.sh" "${VERSION}/dispatch_train_after_probe_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done
bash -n "${VERSION}/run_train.sh" "${VERSION}/probe_one_batch.sh" "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -q 'VLM_INPUT_CHECKPOINT=.*VLM_CKPT' "${VERSION}/run_train.sh"
rg -q -- '--freeze_vision_tower' "${VERSION}/run_train.sh"
rg -q -- '--predictive_coding_head' "${VERSION}/run_train.sh"
rg -q -- '--max_steps "\$\{MAX_STEPS\}"' "${VERSION}/run_train.sh"
rg -F -q '"${OPENPI_PYTHON}" -m torch.distributed.run' "${VERSION}/run_train.sh"
! rg -q '^torchrun ' "${VERSION}/run_train.sh"
rg -F -q 'tokenizer_compat_overlay=' "${VERSION}/run_train.sh"
rg -F -q 'COMPAT_MODEL_DIR' "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -F -q 'VLM_INPUT_CHECKPOINT=${COMPAT_MODEL_DIR}' "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -q 'run_probe 4' "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -q 'run_probe 2' "${VERSION}/dispatch_train_after_probe_zzhang510.sh"
rg -q 'ORACLE' "${VERSION}/PRE_TRAIN.md" && { echo 'PRE_TRAIN may not add oracle behavior' >&2; exit 1; } || true
echo 'task22 v3 training contract: PASS'
