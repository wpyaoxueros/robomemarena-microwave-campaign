#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are missing or unreadable" >&2; exit 2; }

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_ROOT="${VERSION_DIR}/outputs/task22_v7_legacy_seed104_acd1_6_${STAMP}"
SESSION="task22v7_${STAMP}"
mkdir -p "${OUT_ROOT}"
[[ -w "${OUT_ROOT}" ]] || { echo "output is not writable" >&2; exit 2; }

tmux -f /dev/null -L hlei573borrow new-session -d -s "${SESSION}" \
  "bash -lc 'cd ${VERSION_DIR} && STAMP=${STAMP} OUT_ROOT=${OUT_ROOT} bash ${VERSION_DIR}/watch_and_run_zzhang510.sh ${PRIVATE_INPUTS_FILE} 2>&1 | tee -a ${OUT_ROOT}/watcher_console.log; rc=\\\${PIPESTATUS[0]}; echo [TMUX_EXIT] status=\\\${rc}; exec bash'"

printf 'session=%s\nout_root=%s\n' "${SESSION}" "${OUT_ROOT}"
