#!/usr/bin/env bash
set -euo pipefail

[[ "$#" == "1" ]] || { echo "usage: $0 <runtime-env-dir>" >&2; exit 2; }
RUNTIME_ENV_DIR="$1"
[[ -d "${RUNTIME_ENV_DIR}" ]] || { echo "missing runtime env dir" >&2; exit 2; }
: "${SLURM_PROCID:?run under the V131 five-task srun allocation}"
WORKER_ID="${SLURM_PROCID}"
[[ "${WORKER_ID}" =~ ^[0-4]$ ]] || { echo "SLURM_PROCID must be 0..4" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
V130_WORKER="${PACK_DIR}/versions/v130_fixed_seed107_repeat20_v127/run_worker.sh"
RUNTIME_ENV="${RUNTIME_ENV_DIR}/worker${WORKER_ID}.env"
[[ -r "${RUNTIME_ENV}" ]] || { echo "missing worker runtime env" >&2; exit 2; }

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"
WORKER_ROOT="${BATCH_ROOT}/worker${WORKER_ID}"
mkdir -p "${WORKER_ROOT}"
printf 'slurm_job_id=%s\nslurm_proc_id=%s\nhostname=%s\nstarted_at=%s\n' \
  "${SLURM_JOB_ID:-}" "${SLURM_PROCID}" "$(hostname)" "$(date -Is)" >"${WORKER_ROOT}/ALLOCATION.txt"
exec bash "${V130_WORKER}" "${RUNTIME_ENV}"
