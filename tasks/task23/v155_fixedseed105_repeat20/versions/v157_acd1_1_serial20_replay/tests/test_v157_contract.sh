#!/usr/bin/env bash
set -euo pipefail

VERSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "${VERSION_DIR}/run_serial20.sh"
bash -n "${VERSION_DIR}/submit_serial20_zzhang510.sh"
grep -Fq 'REPEATS="${REPEATS:-20}"' "${VERSION_DIR}/run_serial20.sh"
grep -Fq '[[ "${REPEATS}" == "20" ]]' "${VERSION_DIR}/run_serial20.sh"
grep -Fq 'NUM_TRIALS=1' "${VERSION_DIR}/run_serial20.sh"
grep -Fq 'SEED="${FIXED_SEED}"' "${VERSION_DIR}/run_serial20.sh"
grep -Fq 'exit "${rc}"' "${VERSION_DIR}/run_serial20.sh"
grep -Fq -- '--nodelist=${NODE}' "${VERSION_DIR}/submit_serial20_zzhang510.sh"
grep -Fq 'NODE="${NODE:-ACD1-1}"' "${VERSION_DIR}/submit_serial20_zzhang510.sh"
printf 'PASS: Task23 v157 serial fixed-seed contract\n'
