#!/usr/bin/env python3
"""Capture the exact GPU allocation before a two-rank Task22 train starts."""

from __future__ import annotations

import argparse
import csv
import json
import os
import socket
import subprocess
import sys
from pathlib import Path


def _run(command: list[str]) -> str:
    completed = subprocess.run(command, check=True, capture_output=True, text=True)
    return completed.stdout.strip()


def _csv(command: list[str], fields: list[str]) -> list[dict[str, str]]:
    output = _run(command)
    if not output:
        return []
    reader = csv.reader(output.splitlines())
    return [dict(zip(fields, (value.strip() for value in row), strict=True)) for row in reader]


def _visible_devices() -> list[dict[str, str]]:
    import torch

    result: list[dict[str, str]] = []
    for ordinal in range(torch.cuda.device_count()):
        properties = torch.cuda.get_device_properties(ordinal)
        result.append(
            {
                "ordinal": str(ordinal),
                "name": str(properties.name),
                "uuid": str(getattr(properties, "uuid", "")),
                "total_memory": str(properties.total_memory),
            }
        )
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--expected-world-size", required=True, type=int)
    parser.add_argument("--require-clean", action="store_true")
    args = parser.parse_args()

    physical = _csv(
        [
            "nvidia-smi",
            "--query-gpu=index,uuid,name,memory.total,memory.used",
            "--format=csv,noheader,nounits",
        ],
        ["index", "uuid", "name", "memory_total_mib", "memory_used_mib"],
    )
    compute_apps = _csv(
        [
            "nvidia-smi",
            "--query-compute-apps=pid,process_name,used_gpu_memory,gpu_uuid",
            "--format=csv,noheader,nounits",
        ],
        ["pid", "process_name", "used_gpu_memory_mib", "gpu_uuid"],
    )
    visible = _visible_devices()
    visible_uuids = {item["uuid"] for item in visible if item["uuid"]}
    existing_visible_apps = [item for item in compute_apps if item["gpu_uuid"] in visible_uuids]

    report = {
        "hostname": socket.gethostname(),
        "slurm_job_id": os.environ.get("SLURM_JOB_ID", ""),
        "slurm_job_gpus": os.environ.get("SLURM_JOB_GPUS", ""),
        "cuda_visible_devices": os.environ.get("CUDA_VISIBLE_DEVICES", ""),
        "expected_world_size": args.expected_world_size,
        "visible_devices": visible,
        "physical_devices": physical,
        "existing_visible_compute_apps": existing_visible_apps,
        "require_clean": args.require_clean,
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("[TASK22_V4_GPU_PREFLIGHT] " + json.dumps(report, sort_keys=True))

    if len(visible) != args.expected_world_size:
        print(
            f"expected {args.expected_world_size} CUDA-visible devices, got {len(visible)}",
            file=sys.stderr,
        )
        return 4
    if len(visible_uuids) != args.expected_world_size:
        print("CUDA-visible device UUIDs are missing or duplicated", file=sys.stderr)
        return 5
    if args.require_clean and existing_visible_apps:
        print("allocated GPU already has compute processes", file=sys.stderr)
        return 6
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
