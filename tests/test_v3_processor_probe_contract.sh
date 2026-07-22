#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROBE="${REPO}/versions/v3_native_pour_boundary_upweight/probe_processor_compat.sh"
LAUNCHER="${REPO}/versions/v3_native_pour_boundary_upweight/launch_processor_probe_zzhang510.sh"

[[ -s "${PROBE}" ]] || { echo "missing ${PROBE}" >&2; exit 1; }
[[ -s "${LAUNCHER}" ]] || { echo "missing ${LAUNCHER}" >&2; exit 1; }
bash -n "${PROBE}" "${LAUNCHER}"
rg -F -q ': "${COMPAT_MODEL_DIR:?set COMPAT_MODEL_DIR}"' "${PROBE}"
rg -F -q 'AutoProcessor.from_pretrained' "${PROBE}"
rg -F -q 'PYTHONNOUSERSITE=1' "${PROBE}"
! rg -q 'ORACLE_' "${PROBE}"
rg -F -q 'srun -p acd_u --gres=gpu:1' "${LAUNCHER}"
rg -F -q 'task22compatalloc_' "${LAUNCHER}"
echo 'task22 v3 processor compatibility probe contract: PASS'
