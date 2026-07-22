#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"

: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE to an untracked local env file}"
: "${SEED:?set SEED}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -f "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }

# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
for required in OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH ROBOMEMARENA_REMOTE_ROOT TASK21_DATA_ROOT VLA_POLICY VLM_CKPT; do
  [[ -n "${!required:-}" ]] || { echo "missing ${required} in private inputs" >&2; exit 2; }
done

export STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
export RUN_ID="${RUN_ID:-task21_v126_seed${SEED}_${STAMP}}"
export OUT_ROOT="${OUT_ROOT:-${OUTPUT_ROOT}/${RUN_ID}}"
export REPRO_ENTRY_LAUNCHER="${BASH_SOURCE[0]}"
export TASK21_RELEASE_ANCHOR_TEMPLATE="${VERSION_DIR}/release_anchors.empty.object.json"

exec bash "${PACK_DIR}/scripts/run_task21_v121.sh"
