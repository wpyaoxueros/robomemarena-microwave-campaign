#!/usr/bin/env bash
set -euo pipefail

TASK_ID=${1:?usage: preflight_archived_direct20_single_gpu.sh TASK_ID}
CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_ROOT=${OUTPUT_ROOT:?set OUTPUT_ROOT}

# The complete launcher validates every asset.  This preflight additionally
# requires exactly one GPU but exits before constructing an environment.
[[ -n "${SLURM_JOB_ID:-}" ]] || { echo "must run inside a Slurm allocation" >&2; exit 2; }
[[ -n "${CUDA_VISIBLE_DEVICES:-}" ]] || { echo "Slurm did not expose a GPU" >&2; exit 2; }
IFS=',' read -r -a visible_gpus <<<"${CUDA_VISIBLE_DEVICES}"
[[ ${#visible_gpus[@]} -eq 1 ]] || { echo "need one GPU, got ${CUDA_VISIBLE_DEVICES}" >&2; exit 2; }

case "${TASK_ID}" in 1|3|25|26) ;; *) echo "unsupported task: ${TASK_ID}" >&2; exit 2;; esac

test -w "${OUTPUT_ROOT}" || { echo "output root not writable: ${OUTPUT_ROOT}" >&2; exit 3; }
test -x "${CAMPAIGN_DIR}/scripts/run_archived_direct20_single_gpu.sh"
printf 'PREFLIGHT_OK task=%s user=%s job=%s gpu=%s\n' \
  "${TASK_ID}" "$(id -un)" "${SLURM_JOB_ID}" "${CUDA_VISIBLE_DEVICES}"
