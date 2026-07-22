#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_DIR="${REPO_DIR}/versions/v132_v131_multiseed20_five_nodes"
RUNTIME_DIR="${VERSION_DIR}/runtime/task24"

for file in \
  "${VERSION_DIR}/run_one.sh" \
  "${VERSION_DIR}/run_worker.sh" \
  "${VERSION_DIR}/run_multinode_worker.sh" \
  "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" \
  "${VERSION_DIR}/validate_episode.py" \
  "${VERSION_DIR}/aggregate_multiseed20.py" \
  "${RUNTIME_DIR}/scripts/run_task24_v130_pickpopcorn_tol007_keepdirection_latest622_1ep.sh"; do
  [[ -f "${file}" ]] || { echo "missing ${file}" >&2; exit 1; }
done

bash -n "${VERSION_DIR}/run_one.sh"
bash -n "${VERSION_DIR}/run_worker.sh"
bash -n "${VERSION_DIR}/run_multinode_worker.sh"
bash -n "${VERSION_DIR}/dispatch_20ep_zzhang510.sh"
python3 -m py_compile "${VERSION_DIR}/validate_episode.py" "${VERSION_DIR}/aggregate_multiseed20.py"

python3 - "${RUNTIME_DIR}/config/task24_pickpopcorn_tol007_20260718.json" <<'PY'
import json
import sys

config = json.load(open(sys.argv[1], encoding="utf-8"))
assert config["pick popcorn"] == 0.07, config
PY

rg -F 'export MODE=vlm_free' "${VERSION_DIR}/run_one.sh" >/dev/null
rg -F 'ORACLE_HOLD_RELEASE_NEXT=0' "${RUNTIME_DIR}/scripts/run_task23_24_v112_historicalvlm_eef_pickfinish50_latest622_1ep.sh" >/dev/null
rg -F 'ENDPOSE_PLACE_OBJECT_GATE_JSON=' "${RUNTIME_DIR}/scripts/run_task23_24_v112_historicalvlm_eef_pickfinish50_latest622_1ep.sh" >/dev/null
rg -F '"object_anchor": false' "${RUNTIME_DIR}/config/release_anchors_t21_t23_t24_no_pick2place_robotonly_20260718.json" >/dev/null
rg -F 'task2_26_reference_stage.py' "${RUNTIME_DIR}/scripts/launch_one_sync_hold_orig35999.sh" >/dev/null
rg -F -- '--nodes=5' "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" >/dev/null
rg -F 'SEED_START=104' "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" >/dev/null
rg -F 'safe.directory' "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" >/dev/null
rg -F -- '--nodes=5 --ntasks=5 --ntasks-per-node=1' "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" >/dev/null
rg -F 'seed=$((SEED_START + global_episode))' "${VERSION_DIR}/run_worker.sh" >/dev/null
version_dir_line="$(rg -n -F 'VERSION_DIR=' "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" | head -1 | cut -d: -f1)"
safe_dir_line="$(rg -n -F 'safe.directory "${REPO_DIR}"' "${VERSION_DIR}/dispatch_20ep_zzhang510.sh" | head -1 | cut -d: -f1)"
(( version_dir_line < safe_dir_line )) || { echo 'REPO_DIR is referenced before initialization' >&2; exit 1; }

if rg -n '/data/user|/home/' "${VERSION_DIR}" --glob '!runtime_source_sha256.tsv'; then
  echo "private filesystem path leaked into public version" >&2
  exit 1
fi

echo 'PASS task24 v132 multiseed20 contract'
