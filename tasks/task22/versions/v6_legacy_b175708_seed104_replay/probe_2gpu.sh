#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }
PARTITION="${PARTITION:-acd_u}"
STAMP="$(date +%Y%m%d_%H%M%S)"
srun --immediate=20 -p "${PARTITION}" --gres=gpu:2 -c8 --mem=163840M --time=00:02:00 \
  --job-name="task22v6probe_${STAMP}" \
  bash -lc 'echo user=$(whoami); echo host=$(hostname); nvidia-smi --query-gpu=index,uuid --format=csv,noheader'

