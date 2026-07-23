#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${REPO}/versions/v4_device_binding_preflight_20260722"

for file in \
  "${VERSION}/collect_gpu_preflight.py" \
  "${VERSION}/probe_gpu_binding.py" \
  "${VERSION}/run_device_binding_probe.sh" \
  "${VERSION}/submit_device_binding_probe_zzhang510.sh"; do
  [[ -s "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION}/run_device_binding_probe.sh" "${VERSION}/submit_device_binding_probe_zzhang510.sh"
rg -F -q 'CUDA_VISIBLE_DEVICES' "${VERSION}/collect_gpu_preflight.py"
rg -F -q 'query-compute-apps=pid,process_name,used_gpu_memory,gpu_uuid' "${VERSION}/collect_gpu_preflight.py"
rg -F -q 'torch.cuda.set_device(local_rank)' "${VERSION}/probe_gpu_binding.py"
rg -F -q 'all_gather_object' "${VERSION}/probe_gpu_binding.py"
rg -F -q -- '--require-clean' "${VERSION}/run_device_binding_probe.sh"
rg -F -q 'srun -p acd_u --gres=gpu:1' "${VERSION}/submit_device_binding_probe_zzhang510.sh"
rg -F -q 'srun -p acd_u --gres=gpu:2' "${VERSION}/submit_device_binding_probe_zzhang510.sh"
! rg -q 'ORACLE_' "${VERSION}"
echo 'task22 v4 device binding probe contract: PASS'
