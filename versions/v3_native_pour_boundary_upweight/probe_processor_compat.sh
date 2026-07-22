#!/usr/bin/env bash
set -euo pipefail

: "${PRIVATE_INPUTS_FILE:?set PRIVATE_INPUTS_FILE}"
: "${COMPAT_MODEL_DIR:?set COMPAT_MODEL_DIR}"
[[ -r "${PRIVATE_INPUTS_FILE}" ]] || { echo "private inputs are unreadable" >&2; exit 2; }
[[ -r "${COMPAT_MODEL_DIR}/tokenizer_config.json" ]] || { echo "compat tokenizer config is unreadable" >&2; exit 2; }
[[ -r "${COMPAT_MODEL_DIR}/tokenizer.json" ]] || { echo "compat tokenizer payload is unreadable" >&2; exit 2; }

# shellcheck disable=SC1090
source "${PRIVATE_INPUTS_FILE}"
: "${OPENPI_ROOT:?private inputs must define OPENPI_ROOT}"
OPENPI_PYTHON="${OPENPI_PYTHON:-$(dirname "${OPENPI_ROOT}")/conda_envs/openpi/bin/python}"
[[ -x "${OPENPI_PYTHON}" ]] || { echo "missing OpenPI Python" >&2; exit 2; }

export PYTHONNOUSERSITE=1
export TOKENIZERS_PARALLELISM=false
export COMPAT_MODEL_DIR
"${OPENPI_PYTHON}" - <<'PY'
import json
import os

from transformers import AutoProcessor

processor = AutoProcessor.from_pretrained(os.environ["COMPAT_MODEL_DIR"], trust_remote_code=True)
tokenizer = processor.tokenizer
tokens = ["<|vision_start|>", "<|vision_end|>", "<|vision_pad|>", "<|image_pad|>", "<|video_pad|>"]
token_ids = {token: tokenizer.convert_tokens_to_ids(token) for token in tokens}
unk_id = tokenizer.unk_token_id
if any(token_id is None or token_id == unk_id for token_id in token_ids.values()):
    raise RuntimeError(f"missing preserved multimodal token: {token_ids}")
print(json.dumps({"processor": type(processor).__name__, "preserved_token_ids": token_ids}, sort_keys=True))
PY
