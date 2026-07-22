#!/usr/bin/env python3
"""Verify that each torchrun rank selects a distinct allocated GPU."""

from __future__ import annotations

import argparse
import json
import os
import socket
from pathlib import Path

import torch
import torch.distributed as dist


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()

    local_rank = int(os.environ["LOCAL_RANK"])
    world_size = int(os.environ["WORLD_SIZE"])
    torch.cuda.set_device(local_rank)
    dist.init_process_group(backend="nccl")
    properties = torch.cuda.get_device_properties(local_rank)
    payload = {
        "hostname": socket.gethostname(),
        "rank": dist.get_rank(),
        "local_rank": local_rank,
        "world_size": world_size,
        "cuda_visible_devices": os.environ.get("CUDA_VISIBLE_DEVICES", ""),
        "current_device": torch.cuda.current_device(),
        "device_name": str(properties.name),
        "device_uuid": str(getattr(properties, "uuid", "")),
    }
    reports: list[dict[str, object] | None] = [None] * world_size
    dist.all_gather_object(reports, payload)

    status = torch.zeros(1, device=local_rank, dtype=torch.int32)
    if dist.get_rank() == 0:
        resolved = [item for item in reports if item is not None]
        passed = (
            len(resolved) == world_size
            and {item["local_rank"] for item in resolved} == set(range(world_size))
            and all(item["current_device"] == item["local_rank"] for item in resolved)
            and len({str(item["device_uuid"]) for item in resolved}) == world_size
            and all(str(item["device_uuid"]) for item in resolved)
        )
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(resolved, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print("[TASK22_V4_GPU_RANK_BINDING] " + json.dumps(resolved, sort_keys=True))
        if not passed:
            status.fill_(1)
    dist.broadcast(status, src=0)
    dist.destroy_process_group()
    return int(status.item())


if __name__ == "__main__":
    raise SystemExit(main())
