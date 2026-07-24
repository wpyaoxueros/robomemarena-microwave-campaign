#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVALUATOR="${PACK_DIR}/evaluators/eval_counting_autonomous_pour_return_assist_d9f83ac.py"
RUNNER="${PACK_DIR}/scripts/run_autonomous_task.sh"
ENTRYPOINT="${PACK_DIR}/run_task16_29ep.sh"

[[ -f "${EVALUATOR}" ]]
grep -Fq 'POUR_RETURN_ASSIST' "${EVALUATOR}"
grep -Fq '_build_return_action' "${EVALUATOR}"
grep -Fq '_install_pour_return_env_patch' "${EVALUATOR}"
grep -Fq 'POUR_RETURN_ASSIST_ARM' "${EVALUATOR}"
grep -Fq 'POUR_RETURN_ASSIST_DONE' "${EVALUATOR}"
grep -Fq 'action = raw.copy()' "${EVALUATOR}"
if grep -Fq 'action = np.zeros_like(raw)' "${EVALUATOR}"; then
  echo "return assist must not overwrite VLA translation channels" >&2
  exit 1
fi
if grep -Fq 'action[-1] = float(gripper_command)' "${EVALUATOR}"; then
  echo "return assist must not overwrite the VLA gripper channel" >&2
  exit 1
fi
"/data/user/hlei573/openpi_inference/.venv/bin/python" - "${EVALUATOR}" <<'PY'
import ast
import os
import sys
from pathlib import Path
from typing import Any

import numpy as np

module = ast.parse(Path(sys.argv[1]).read_text())
function = next(node for node in module.body if isinstance(node, ast.FunctionDef) and node.name == "_build_return_action")
scope = {"np": np, "os": os, "Any": Any}
exec(compile(ast.Module(body=[function], type_ignores=[]), "<return-action-test>", "exec"), scope)
os.environ["POUR_RETURN_ASSIST_ROTATION_MAGNITUDE"] = "0.8"
raw = np.array([0.12, -0.05, 0.03, 0.10, -0.40, 0.20, 1.0], dtype=np.float32)
returned = scope["_build_return_action"](raw, raw[3:6])
assert np.allclose(returned[:3], raw[:3]), (returned, raw)
assert returned[-1] == raw[-1], (returned, raw)
assert np.allclose(returned[3:6], -raw[3:6] / np.linalg.norm(raw[3:6]) * 0.8), returned
PY
grep -Fq 'POUR_RETURN_ASSIST' "${RUNNER}"
grep -Fq 'POUR_RETURN_ASSIST_TARGET_RADIUS' "${RUNNER}"
grep -Fq 'POUR_RETURN_ASSIST_ROTATION_MAGNITUDE' "${RUNNER}"
grep -Fq 'POUR_RETURN_ASSIST_MAX_STEPS' "${RUNNER}"
grep -Fq 'VLA_POLICY_SEED=100' "${ENTRYPOINT}"
bash -n "${RUNNER}"
bash -n "${ENTRYPOINT}"
grep -Fq 'NUM_TRIALS="${NUM_TRIALS:-29}"' "${ENTRYPOINT}"
grep -Fq 'ORACLE_FORCE_INITIAL_PROMPT=0' "${ENTRYPOINT}"

echo "task16 pour-return assist static contract: PASS"
