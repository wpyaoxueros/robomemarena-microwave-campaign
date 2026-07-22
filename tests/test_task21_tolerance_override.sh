#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT
mkdir -p "${TMP}/bin"

cat >"${TMP}/bin/python3" <<'SH'
#!/bin/bash
set -euo pipefail
while (( "$#" )); do
  case "$1" in
    --output)
      output="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
mkdir -p "$(dirname "${output}")"
printf '{"tasks": {}}\n' >"${output}"
SH
chmod 755 "${TMP}/bin/python3"

cat >"${TMP}/bin/bash" <<'SH'
#!/bin/bash
printf '%s\n' "${ENDPOSE_HOLD_POS_TOL_BY_SUBTASK_FILE}" >>"${TASK21_TOL_CAPTURE:?}"
SH
chmod 755 "${TMP}/bin/bash"

CAPTURE="${TMP}/tolerances.txt"
OVERRIDE="${TMP}/override.json"
printf '{"pick chocolate": 0.05}\n' >"${OVERRIDE}"

run_launcher() {
  PATH="${TMP}/bin:${PATH}" \
  TASK21_TOL_CAPTURE="${CAPTURE}" \
  OPENPI_ROOT=/unused \
  INFER_ROOT=/unused \
  TARGET_LIBERO_PATH=/unused \
  ROBOMEMARENA_REMOTE_ROOT=/unused \
  TASK21_DATA_ROOT=/unused \
  VLA_POLICY=/unused \
  VLM_CKPT=/unused \
  OUTPUT_ROOT="${TMP}/outputs" \
  TASK21_RELEASE_ANCHOR_TEMPLATE="${ROOT}/config/task21_v121_release_anchors.template.json" \
  /bin/bash "${ROOT}/scripts/run_task21_v121.sh"
}

run_launcher
TASK21_HOLD_TOLERANCES="${OVERRIDE}" run_launcher

mapfile -t captured <"${CAPTURE}"
[[ "${captured[0]}" == "${ROOT}/config/task21_v121_eef_tolerances.json" ]]
[[ "${captured[1]}" == "${OVERRIDE}" ]]
printf 'PASS: v121 tolerance default is frozen and version override is explicit\n'
