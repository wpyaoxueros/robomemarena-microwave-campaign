#!/usr/bin/env bash
set -euo pipefail

[[ "$#" == "1" ]] || { echo "usage: $0 <runtime-env>" >&2; exit 2; }
RUNTIME_ENV="$1"
[[ -r "${RUNTIME_ENV}" ]] || { echo "missing runtime env" >&2; exit 2; }

# shellcheck disable=SC1090
source "${RUNTIME_ENV}"
VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V128_DIR="${VERSION_DIR}/../v128_v121_20ep_sharded_latest622"
exec bash "${V128_DIR}/run_shard.sh"
