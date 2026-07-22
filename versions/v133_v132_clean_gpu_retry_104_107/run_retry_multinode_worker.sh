#!/usr/bin/env bash
set -euo pipefail

[[ "$#" == "1" ]] || { echo "usage: $0 <runtime-env-dir>" >&2; exit 2; }
RUNTIME_ENV_DIR="$1"
WORKER_ID="${SLURM_PROCID:?SLURM_PROCID is required}"
[[ "${WORKER_ID}" =~ ^[0-3]$ ]] || { echo "unexpected SLURM_PROCID=${WORKER_ID}" >&2; exit 2; }
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec bash "${VERSION_DIR}/run_retry_worker.sh" "${RUNTIME_ENV_DIR}/worker${WORKER_ID}.env"
