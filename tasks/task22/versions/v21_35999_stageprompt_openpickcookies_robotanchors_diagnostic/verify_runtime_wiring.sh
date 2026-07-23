#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
ACTIVE_EVAL="${VERSION_DIR}/runtime/eval_tasks2_26_task22_stageprompt_openpickcookies_robotanchors_diagnostic.py"
LAUNCHER="${VERSION_DIR}/runtime/launch_one_sync_hold_orig35999_v21.sh"

[[ -x "${LAUNCHER}" ]] || { echo "missing v21 launcher" >&2; exit 2; }
[[ -f "${ACTIVE_EVAL}" ]] || { echo "missing v21 evaluator" >&2; exit 2; }

actual="$(
  TASK22_V21_WIRING_ONLY=1 \
    TASK22_V21_PACK_DIR_OVERRIDE="${PACK_DIR}" \
    EVAL_PY_OVERRIDE="${ACTIVE_EVAL}" \
    bash "${LAUNCHER}" 22
)"
[[ "${actual}" == "V21_ACTIVE_EVAL_PY=${ACTIVE_EVAL}" ]] || {
  printf 'v21 evaluator wiring mismatch: %s\n' "${actual}" >&2
  exit 3
}
printf 'TASK22_STAGEPROMPT_OPENPICKCOOKIES_ROBOTANCHORS_RUNTIME_WIRING_OK\n'
