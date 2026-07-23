#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_INPUTS_FILE="${1:?usage: $0 /absolute/path/to/inputs.env}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "historical inputs are unreadable" >&2; exit 2; }
# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"

for required in OPENPI_ROOT INFER_ROOT TARGET_LIBERO_PATH VLM_CKPT VLA_POLICY VLA_CONFIG VLA_REPO_ID; do
  [[ -n "${!required:-}" ]] || { echo "missing ${required}" >&2; exit 2; }
done
for readable in "${OPENPI_ROOT}" "${INFER_ROOT}" "${TARGET_LIBERO_PATH}" "${VLM_CKPT}" "${VLA_POLICY}" "${VLA_REPO_ID}"; do
  [[ -r "${readable}" ]] || { echo "unreadable historical input" >&2; exit 2; }
done
[[ "${VLA_CONFIG}" == "pi05_libero_robomemarena_fullvlm_v2_noflip_dataset" ]] || {
  echo "unexpected VLA config" >&2
  exit 2
}

expected() {
  awk -F '\t' -v key="$1" '$1 == key { print $2; exit }' "${VERSION_DIR}/HISTORICAL_INPUT_FINGERPRINTS.tsv"
}
check_value() {
  local key="$1"
  local actual="$2"
  local wanted
  wanted="$(expected "${key}")"
  [[ -n "${wanted}" && "${actual}" == "${wanted}" ]] || {
    echo "historical input fingerprint mismatch: ${key}" >&2
    exit 1
  }
}
path_digest() {
  printf '%s' "$1" | sha256sum | awk '{print $1}'
}
file_digest() {
  sha256sum "$1" | awk '{print $1}'
}

check_value VLM_CKPT_PATH "$(path_digest "${VLM_CKPT}")"
check_value VLA_POLICY_PATH "$(path_digest "${VLA_POLICY}")"
check_value VLA_REPO_ID_PATH "$(path_digest "${VLA_REPO_ID}")"
check_value TARGET_LIBERO_PATH "$(path_digest "${TARGET_LIBERO_PATH}")"
check_value VLA_PARAMS_MANIFEST "$(find "${VLA_POLICY}/params" -maxdepth 2 -type f -printf '%P %s\n' | LC_ALL=C sort | sha256sum | awk '{print $1}')"
check_value NORM_STATS "$(file_digest "${VLA_REPO_ID}/norm_stats.json")"
check_value LIBERO_ENV_VENV "$(file_digest "${TARGET_LIBERO_PATH}/envs/venv.py")"
check_value LIBERO_BDDL_BASE_DOMAIN "$(file_digest "${TARGET_LIBERO_PATH}/envs/bddl_base_domain.py")"
check_value LIBERO_BDDL_UTILS "$(file_digest "${TARGET_LIBERO_PATH}/envs/bddl_utils.py")"
check_value LIBERO_WOODEN_CABINET "$(file_digest "${TARGET_LIBERO_PATH}/assets/articulated_objects/wooden_cabinet.xml")"

printf 'HISTORICAL_INPUT_LOCK_OK\n'
