#!/usr/bin/env bash
set -euo pipefail

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUBMITTER="${CAMPAIGN_DIR}/scripts/submit_task21_d9_direct20_single_gpu.sh"

[[ -f "${SUBMITTER}" ]] || { echo "missing Task21 submitter: ${SUBMITTER}" >&2; exit 1; }
bash -n "${SUBMITTER}"

grep -Fq 'tmux -f /dev/null new-session -d' "${SUBMITTER}"
grep -Fq 'srun -p acd_u --gres=gpu:1' "${SUBMITTER}"
grep -Fq 'run_task21_d9_direct20_single_gpu.sh' "${SUBMITTER}"
grep -Fq 'MEM_MB=${MEM_MB:-131072}' "${SUBMITTER}"
! grep -Fq -- ' -A ' "${SUBMITTER}"

echo "PASS Task21 d9 submitter contract"
