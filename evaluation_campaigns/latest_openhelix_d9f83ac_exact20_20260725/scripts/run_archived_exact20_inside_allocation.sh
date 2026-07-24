#!/usr/bin/env bash
set -euo pipefail

# Run one frozen archived task in an already allocated zzhang510 Slurm job.
# Checkpoint paths arrive only through the untracked runtime environment file.

TASK_ID=${1:?usage: run_archived_exact20_inside_allocation.sh TASK_ID RUNTIME_ENV}
RUNTIME_ENV=${2:?usage: run_archived_exact20_inside_allocation.sh TASK_ID RUNTIME_ENV}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${TASK_ID}" in
  1|3|12|13|18|25|26) ;;
  *) echo "unsupported archived task: ${TASK_ID}" >&2; exit 2 ;;
esac

[[ -f "${RUNTIME_ENV}" ]] || { echo "missing runtime env: ${RUNTIME_ENV}" >&2; exit 2; }
[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside Slurm" >&2; exit 2; }

export NUM_TRIALS=20
export SEED=${SEED:-104}
export PORT=${PORT:-$((9400 + TASK_ID))}
export RUNTIME_ENV

exec "${CAMPAIGN_DIR}/scripts/run_archived_task_exact20.sh" "${TASK_ID}"
