#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${VERSION_DIR}"

sha256sum -c SOURCE_SHA256.tsv
grep -Fq 'task_id\ttrial\tseed\tvlm_ckpt\tvla_prompt_last\ttsr\tcsr' \
  runtime/evaluation_benchmark/async_vlm26_reference/eval_fullvlm26_async_vlm_vla.py
grep -Fq 'Episode %s seed=%s CSR=%.1f TSR=%s' \
  runtime/evaluation_benchmark/async_vlm26_reference/eval_fullvlm26_async_vlm_vla.py
grep -Fq 'async VLM enabled: single-slot subtask buffer' \
  runtime/evaluation_benchmark/async_vlm26_reference/eval_fullvlm26_async_vlm_vla.py
echo "LEGACY_SNAPSHOT_OK commit=b175708317abacfbce86c4911cc492d68a3ea163"
