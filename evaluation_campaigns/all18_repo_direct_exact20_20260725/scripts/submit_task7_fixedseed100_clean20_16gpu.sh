#!/usr/bin/env bash
set -euo pipefail

CAMPAIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${CAMPAIGN_DIR}/../.." && pwd)"
WORKER="${CAMPAIGN_DIR}/scripts/run_task7_fixed_seed_repeat_worker.sh"

if [[ "${1:-}" == "--workers" ]]; then
  RUN_ROOT="$2"
  WORKER="$3"
  STAMP="$4"
  EXCLUDE_NODES="$5"
  read -r -a REPEATS <<<"$6"

  for WORKER_ID in "${!REPEATS[@]}"; do
    PORT_BASE="$((32000 + WORKER_ID * 100))"
    srun -p acd_u -c 8 --gres=gpu:2 --mem=160G --exclude="${EXCLUDE_NODES}" \
      --job-name="lhs_t7s100_clean_w${WORKER_ID}_${STAMP}" \
      env OUTPUT_ROOT="${RUN_ROOT}" WORKER_ID="${WORKER_ID}" \
        REPEAT_COUNT="${REPEATS[WORKER_ID]}" FIXED_SEED=100 PORT_BASE="${PORT_BASE}" \
      bash "${WORKER}" >"${RUN_ROOT}/worker${WORKER_ID}.submit.log" 2>&1 &
  done
  wait
  exit 0
fi

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RUN_ROOT="${REPO_DIR}/evidence/runs/task7_fixedseed100_clean20_16gpu_${STAMP}"
SESSION="lhs_t7s100_clean20_${STAMP}"
EXCLUDE_NODES="ACD1-31,ACD1-39,ACD1-58,ACD1-9"
REPEATS=(3 3 3 3 2 2 2 2)

[[ -x "${WORKER}" ]] || { echo "missing worker: ${WORKER}" >&2; exit 2; }
mkdir -p "${RUN_ROOT}"
chmod 2775 "${RUN_ROOT}"

cat >"${RUN_ROOT}/launch_manifest.env" <<EOF
campaign=task7_fixedseed100_clean20_16gpu
fixed_seed=100
workers=8
repeat_counts=${REPEATS[*]}
total_episodes=20
topology=two_gpu_vla_vlm
official_commit=d9f83ac5182e25ad7f0a301a77a0b667f2392df1
excluded_abort_nodes=${EXCLUDE_NODES}
oracle_prompt_injection=off
object_anchor=off
EOF

tmux -f /dev/null new-session -d -s "${SESSION}" \
  "bash '${BASH_SOURCE[0]}' --workers '${RUN_ROOT}' '${WORKER}' '${STAMP}' '${EXCLUDE_NODES}' '${REPEATS[*]}'"

echo "session=${SESSION}"
echo "run_root=${RUN_ROOT}"
