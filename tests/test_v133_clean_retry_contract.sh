#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_DIR="${REPO_DIR}/versions/v133_v132_clean_gpu_retry_104_107"

for file in \
  "${VERSION_DIR}/dispatch_retry_zzhang510.sh" \
  "${VERSION_DIR}/run_retry_multinode_worker.sh" \
  "${VERSION_DIR}/run_retry_worker.sh" \
  "${VERSION_DIR}/PRE_RUN.md"; do
  [[ -f "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION_DIR}/dispatch_retry_zzhang510.sh"
bash -n "${VERSION_DIR}/run_retry_multinode_worker.sh"
bash -n "${VERSION_DIR}/run_retry_worker.sh"
rg -F 'RETRY_SEEDS=(104 105 106 107)' "${VERSION_DIR}/dispatch_retry_zzhang510.sh" >/dev/null
rg -F 'EXCLUDE_NODE="${EXCLUDE_NODE:-ACD1-1}"' "${VERSION_DIR}/dispatch_retry_zzhang510.sh" >/dev/null
rg -F -- '--nodes=4 --ntasks=4 --ntasks-per-node=1 --gres=gpu:2' "${VERSION_DIR}/dispatch_retry_zzhang510.sh" >/dev/null
rg -F 'GPU_PREFLIGHT_MAX_MIB="${GPU_PREFLIGHT_MAX_MIB:-4096}"' "${VERSION_DIR}/run_retry_worker.sh" >/dev/null
rg -F 'SOURCE_VERSION_DIR="${VERSION_DIR}/../v132_v131_multiseed20_five_nodes"' "${VERSION_DIR}/run_retry_worker.sh" >/dev/null
rg -F 'run_one.sh' "${VERSION_DIR}/run_retry_worker.sh" >/dev/null

if rg -n '/data/user|/home/' "${VERSION_DIR}"; then
  echo 'private filesystem path leaked into public retry version' >&2
  exit 1
fi

echo 'PASS task24 v133 clean retry contract'
