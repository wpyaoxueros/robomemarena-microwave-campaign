#!/usr/bin/env python3
"""Contract test for the private Task22 tokenizer compatibility overlay."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
SCRIPT = REPO / "scripts" / "materialize_tokenizer_compat_overlay.py"


def main() -> None:
    assert SCRIPT.is_file(), f"missing {SCRIPT}"

    with tempfile.TemporaryDirectory() as temp_dir:
        root = Path(temp_dir)
        source = root / "source_model"
        output = root / "compat_model"
        source.mkdir()

        tokens = ["<|vision_start|>", "<|vision_end|>", "<|image_pad|>"]
        (source / "tokenizer_config.json").write_text(
            json.dumps({"extra_special_tokens": tokens, "tokenizer_class": "Qwen2TokenizerFast"}),
            encoding="utf-8",
        )
        (source / "tokenizer.json").write_text(
            json.dumps({"added_tokens": [{"content": token} for token in tokens]}),
            encoding="utf-8",
        )
        (source / "config.json").write_text(
            json.dumps(
                {
                    "model_type": "qwen3_vl",
                    "text_config": {
                        "rope_parameters": {
                            "mrope_interleaved": True,
                            "mrope_section": [24, 20, 20],
                            "rope_theta": 5_000_000,
                            "rope_type": "default",
                        }
                    },
                }
            ),
            encoding="utf-8",
        )
        (source / "model.safetensors").write_bytes(b"weights")

        subprocess.run(
            [sys.executable, str(SCRIPT), "--source", str(source), "--output", str(output)],
            check=True,
        )

        with (output / "tokenizer_config.json").open(encoding="utf-8") as handle:
            config = json.load(handle)
        assert config["extra_special_tokens"] == {}
        with (output / "config.json").open(encoding="utf-8") as handle:
            model_config = json.load(handle)
        text_config = model_config["text_config"]
        assert text_config["rope_theta"] == 5_000_000
        assert text_config["rope_scaling"] == {
            "mrope_interleaved": True,
            "mrope_section": [24, 20, 20],
            "rope_type": "default",
        }
        assert "rope_parameters" not in text_config
        assert (output / "model.safetensors").is_symlink()
        assert (output / "model.safetensors").read_bytes() == b"weights"

        with (output / "compat_manifest.json").open(encoding="utf-8") as handle:
            manifest = json.load(handle)
        assert manifest["source_extra_special_tokens_type"] == "list"
        assert manifest["preserved_token_count"] == len(tokens)
        assert manifest["rope_parameters_normalized"] is True
        assert "source_path" not in manifest

    print("task22 tokenizer compatibility overlay: PASS")


if __name__ == "__main__":
    main()
