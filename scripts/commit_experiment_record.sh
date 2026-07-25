#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "usage: $0 <SUCCESS|FAILED|INVALID|IN_PROGRESS> <message> <paths...>" >&2
  exit 2
fi

STATUS="$1"
MESSAGE="$2"
shift 2

case "$STATUS" in
  SUCCESS|FAILED|INVALID|IN_PROGRESS) ;;
  *)
    echo "invalid experiment status: $STATUS" >&2
    exit 2
    ;;
esac

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
python3 scripts/validate_experiment_ledger.py --check-local
git add -- "$@"
git diff --cached --quiet && {
  echo "no staged changes" >&2
  exit 1
}
git commit -m "$STATUS: $MESSAGE"
