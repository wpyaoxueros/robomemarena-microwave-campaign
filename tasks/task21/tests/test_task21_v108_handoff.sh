#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT
mkdir -p "${TMP}/bin"

cat >"${TMP}/bin/bash" <<'SH'
#!/bin/bash
printf '%s\n' "${ENDPOSE_HOLD_RELEASE_MIN_STEPS_BY_SUBTASK_FILE}" >"${TASK21_HANDOFF_CAPTURE:?}"
SH
chmod 755 "${TMP}/bin/bash"

CAPTURE="${TMP}/handoff.txt"
PATH="${TMP}/bin:${PATH}" \
TASK21_HANDOFF_CAPTURE="${CAPTURE}" \
VLM_CKPT="/unused" \
ENDPOSE_HOLD_RELEASE_MIN_STEPS_BY_SUBTASK_FILE="${ROOT}/config/task21_v121_min_hold_steps.json" \
/bin/bash "${ROOT}/scripts/run_task21_v108_historicalvlm_eef_latest622_1ep.sh"

expected="${ROOT}/config/task21_v121_min_hold_steps.json"
actual="$(cat "${CAPTURE}")"
[[ "${actual}" == "${expected}" ]]
printf 'PASS: v108 preserves caller min-hold config\n'
