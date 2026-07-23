#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANCHORS="${ROOT}/config/release_anchors_task23_v153_no_final_anchor.json"
TARGETS="${ROOT}/config/tasks2_26_endpose_targets_seed100_199_no_task23_placepopcorn.json"
LAUNCHER="${ROOT}/run_task23_v154.sh"
SUBMIT="${ROOT}/submit_zzhang510.sh"

jq -e '
  .tasks["23"] | length == 2 and
  all(.[]; .released != "pick popcorn" and .next != "place popcorn")
' "${ANCHORS}" >/dev/null
jq -e '(.tasks["23"].subtasks | has("place popcorn")) | not' "${TARGETS}" >/dev/null
rg -q 'release_anchors_task23_v153_no_final_anchor\.json' "${LAUNCHER}"
rg -q 'RUN_ID="\$\{RUN_ID:-task23_v154_no_final_anchor_20ep_tmux_env\}"' "${LAUNCHER}"
rg -q 'NUM_TRIALS=\$\{NUM_TRIALS:-1\} SEED=\$\{SEED:-105\}' "${SUBMIT}"

echo 'PASS: v154 has exactly two anchors, no place-popcorn target/anchor, and forwards shard seed/trial values'
