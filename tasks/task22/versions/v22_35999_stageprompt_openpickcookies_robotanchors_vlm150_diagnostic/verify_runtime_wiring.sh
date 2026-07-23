#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
ACTIVE_EVAL="${VERSION_DIR}/runtime/eval_tasks2_26_task22_stageprompt_openpickcookies_robotanchors_vlm150_diagnostic.py"
LAUNCHER="${VERSION_DIR}/runtime/launch_one_sync_hold_orig35999_v22.sh"

[[ -x "${LAUNCHER}" ]] || { echo "missing v22 launcher" >&2; exit 2; }
[[ -f "${ACTIVE_EVAL}" ]] || { echo "missing v22 evaluator" >&2; exit 2; }

actual="$(
  TASK22_V22_WIRING_ONLY=1 \
    TASK22_V22_PACK_DIR_OVERRIDE="${PACK_DIR}" \
    EVAL_PY_OVERRIDE="${ACTIVE_EVAL}" \
    bash "${LAUNCHER}" 22
)"
[[ "${actual}" == "V22_ACTIVE_EVAL_PY=${ACTIVE_EVAL}" ]] || {
  printf 'v22 evaluator wiring mismatch: %s\n' "${actual}" >&2
  exit 3
}
printf 'TASK22_STAGEPROMPT_OPENPICKCOOKIES_ROBOTANCHORS_RUNTIME_WIRING_OK\n'
