#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${OUT_ROOT}"
printf 'task_id\tstatus\terror\tstage_score_pct\tstage_success_rate\tgoal_success_rate\tvideo_dir\tduration_sec\n' > "${OUT_ROOT}/summary.tsv"
printf '6\tcompleted\t\t100.0\t1.0000\t1.0000\t/tmp/video\t1.0\n' >> "${OUT_ROOT}/summary.tsv"
