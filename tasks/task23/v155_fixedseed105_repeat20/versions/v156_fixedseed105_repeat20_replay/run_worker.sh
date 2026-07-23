#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE to an untracked local env file}"
: "${WORKER_ID:?set WORKER_ID in 0..4}"
: "${PORT:?set PORT}"
: "${OUTPUT_ROOT:?set OUTPUT_ROOT}"
[[ -f "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing PRIVATE_INPUTS_FILE=${PRIVATE_INPUTS_FILE}" >&2; exit 2; }

export WORKER_OUT_ROOT="${WORKER_OUT_ROOT:-${OUTPUT_ROOT}/task23_v156_worker${WORKER_ID}_$(date +%Y%m%d_%H%M%S)}"
export INPUTS_FILE="${PRIVATE_INPUTS_FILE}"
export REPEATS=4
export FIXED_SEED=105
export PORT

exec bash "${PACK_DIR}/scripts/run_fixed_seed_worker.sh"
