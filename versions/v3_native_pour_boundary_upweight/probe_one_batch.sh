#!/usr/bin/env bash
set -euo pipefail

: "${PROBE_BATCH:?set PROBE_BATCH}"
: "${PROBE_OUTPUT_ROOT:?set PROBE_OUTPUT_ROOT}"
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"

export TRAIN_OUTPUT_ROOT="${PROBE_OUTPUT_ROOT}"
export RUN_ID="task22_v3_probe_bs${PROBE_BATCH}_${STAMP}"
export PER_DEVICE_BS="${PROBE_BATCH}"
export GRAD_ACC=1
export MAX_STEPS=1
export SAVE_STEPS=1
export MASTER_PORT="${MASTER_PORT:?set MASTER_PORT}"

exec bash "${VERSION_DIR}/run_train.sh"
