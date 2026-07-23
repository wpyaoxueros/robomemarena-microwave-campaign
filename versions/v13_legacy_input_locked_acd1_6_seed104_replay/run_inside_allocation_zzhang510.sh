#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_VERSION_DIR="${VERSION_DIR}/../v8_legacy_original_runtime_seed104_replay"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
OUT_ROOT="${OUT_ROOT:?OUT_ROOT is required}"
RUN_ID="${RUN_ID:?RUN_ID is required}"
PORT="${PORT:-19722}"

[[ -x "${BASE_VERSION_DIR}/run_legacy_1ep.sh" ]] || { echo "frozen v8 runtime is missing" >&2; exit 2; }
mkdir -p "${OUT_ROOT}"
[[ -w "${OUT_ROOT}" ]] || { echo "output is not writable" >&2; exit 2; }

"${VERSION_DIR}/verify_historical_inputs.sh" "${PRIVATE_INPUTS_FILE}" | tee "${OUT_ROOT}/input_lock.log"
"${BASE_VERSION_DIR}/verify_snapshot.sh" | tee "${OUT_ROOT}/runtime_snapshot.log"

python3 - <<PY
import socket
port = int("${PORT}")
sock = socket.socket()
try:
    sock.bind(("127.0.0.1", port))
except OSError as exc:
    raise SystemExit(f"port {port} is unavailable: {exc}")
finally:
    sock.close()
PY

printf 'user=%s\nhost=%s\nnode_list=%s\nport=%s\n' \
  "$(whoami)" "$(hostname)" "${SLURM_JOB_NODELIST:-}" "${PORT}" > "${OUT_ROOT}/allocation_identity.tsv"
nvidia-smi --query-gpu=index,uuid --format=csv,noheader > "${OUT_ROOT}/gpu_identity.tsv"

cd "${BASE_VERSION_DIR}"
PORT="${PORT}" \
PRIVATE_INPUTS_FILE="${PRIVATE_INPUTS_FILE}" \
OUTPUT_ROOT="${VERSION_DIR}/outputs" \
RUN_ID="${RUN_ID}" \
OUT_ROOT="${OUT_ROOT}" \
bash "${BASE_VERSION_DIR}/run_legacy_1ep.sh" "${PRIVATE_INPUTS_FILE}"
