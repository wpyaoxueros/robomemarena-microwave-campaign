#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILDER="${ROOT}/scripts/materialize_archived_original_execution_pack.py"
INFER_PYTHON=/data/user/hlei573/openpi_inference/.venv/bin/python
OPENPI_ROOT=/data/user/hlei573/openpi
LIBERO_ROOT=/data/user/hlei573/RoboMemArena_github/LIBERO/libero

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

python3 "${BUILDER}" --task-id 2 --output "${tmp}/pack" >/dev/null
mkdir -p "${tmp}/out/videos"

OPENPI_ROOT="${OPENPI_ROOT}" \
OPENPI_INFERENCE_ROOT=/data/user/hlei573/openpi_inference \
TARGET_LIBERO_PATH="${LIBERO_ROOT}" \
ROBOMEMARENA_OFFICIAL_SCRIPTS_DIR="${tmp}/pack/code_snapshot" \
TASKS2_26_BASE_EVAL_PY="${tmp}/pack/RoboMemArena/evaluation_benchmark/reference_evaluation/tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py" \
OUT_ROOT="${tmp}/out" \
VIDEO_DIR="${tmp}/out/videos" \
SUMMARY_JSON="${tmp}/out/summary.json" \
SUMMARY_TSV="${tmp}/out/summary.tsv" \
"${INFER_PYTHON}" - "${tmp}/pack" <<'PY'
import importlib.util
import pathlib
import sys

pack = pathlib.Path(sys.argv[1])
driver = pack / "driver" / "eval_tasks2_26_sync_endpose_hold_officialscore.py"
sys.path.insert(0, str(driver.parent))
spec = importlib.util.spec_from_file_location("frozen_outer_eval_import_probe", driver)
module = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = module
spec.loader.exec_module(module)

expected = pack / "RoboMemArena" / "evaluation_benchmark" / "openpi_minimal_runtime" / "eval_common.py"
actual = pathlib.Path(module.base.ec.__file__).resolve()
assert actual == expected.resolve(), (actual, expected)
print(f"IMPORT_LAYOUT_OK eval_common={actual}")
PY

echo 'PASS archived original snapshot import-layout contract'
