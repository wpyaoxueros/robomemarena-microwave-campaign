#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while IFS='  ' read -r expected relative_path; do
  [[ -n "${expected}" ]] || continue
  actual="$(sha256sum "${VERSION_DIR}/${relative_path}" | awk '{print $1}')"
  [[ "${actual}" == "${expected}" ]] || {
    echo "hash mismatch: ${relative_path}" >&2
    exit 1
  }
done < "${VERSION_DIR}/SOURCE_SHA256.tsv"

helper="${VERSION_DIR}/runtime/evaluation_benchmark/openpi_minimal_runtime/retry_tasks2_26_stage_from_anygrasp.py"
common="${VERSION_DIR}/runtime/evaluation_benchmark/openpi_minimal_runtime/eval_common.py"
grep -Fq 'fallback_x_thresh: float = 0.65' "${helper}"
grep -Fq 'return float(handle_pos[0]) < fallback_x_thresh' "${helper}"
grep -Fq 'z_low: float = -1.0' "${common}"
if grep -Rqs 'ORACLE_' "${VERSION_DIR}/runtime"; then
  echo 'oracle control found in frozen runtime' >&2
  exit 1
fi

echo 'ORIGINAL_RUNTIME_SNAPSHOT_OK'
