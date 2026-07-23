#!/usr/bin/env bash
set -euo pipefail

[[ "${USER:-}" == "zzhang510" ]] || { echo "run from zzhang510" >&2; exit 2; }

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${VERSION_DIR}/../.." && pwd)"
PRIVATE_INPUTS_FILE="${1:-${VERSION_DIR}/inputs.env}"
REMOTE_ROOT_OVERRIDE="${ROBOMEMARENA_REMOTE_ROOT_OVERRIDE:?set ROBOMEMARENA_REMOTE_ROOT_OVERRIDE before submitting}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "missing private inputs" >&2; exit 2; }
PRIVATE_INPUTS_FILE="$(readlink -f "${PRIVATE_INPUTS_FILE}")"
# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
export ROBOMEMARENA_REMOTE_ROOT="${REMOTE_ROOT_OVERRIDE}"
export ROBOMEMARENA_REMOTE_ROOT_OVERRIDE

STAMP="$(date +%Y%m%d_%H%M%S)"
PROBE_DIR="${VERSION_DIR}/outputs/probes/${STAMP}"
mkdir -p "${PROBE_DIR}"

selected_partition=""
for partition in acd_u acd_ue emergency_acd; do
  if srun --immediate=20 -p "${partition}" --gres=gpu:1 -c1 --mem=1024M --time=00:01:00 \
    --job-name="task22v14_1gpu_${STAMP}" bash -lc 'whoami; hostname; nvidia-smi -L' \
    >"${PROBE_DIR}/${partition}_1gpu.log" 2>&1; then
    if srun --immediate=20 -p "${partition}" --gres=gpu:2 -c8 --mem=163840M --time=00:01:00 \
      --job-name="task22v14_2gpu_${STAMP}" bash -lc 'whoami; hostname; nvidia-smi -L' \
      >"${PROBE_DIR}/${partition}_2gpu.log" 2>&1; then
      selected_partition="${partition}"
      break
    fi
  fi
done

if [[ -z "${selected_partition}" ]]; then
  selected_partition=emergency_acd
  printf 'no immediate 2-GPU allocation; queueing formal job on %s\n' "${selected_partition}" \
    >"${PROBE_DIR}/queue_fallback.log"
fi

printf 'selected_partition=%s\n' "${selected_partition}" >"${PROBE_DIR}/selected_partition.tsv"
PARTITION="${selected_partition}" \
  ROBOMEMARENA_REMOTE_ROOT_OVERRIDE="${REMOTE_ROOT_OVERRIDE}" \
  bash "${VERSION_DIR}/launch_1ep_zzhang510.sh" "${PRIVATE_INPUTS_FILE}"
