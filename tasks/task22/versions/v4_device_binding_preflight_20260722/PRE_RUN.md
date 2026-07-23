# Task22 V4 Device-Binding Preflight

This version is an infrastructure diagnostic only. It does not load a VLM
checkpoint, modify Task22 data, inject prompts, or run evaluation.

It records the Slurm allocation, CUDA-visible devices, GPU UUIDs, pre-existing
compute processes, and the device selected by each torchrun rank. A run fails
before model loading if the allocation exposes a different number of GPUs than
the two requested ranks, if an allocated GPU already has a compute process, or
if the ranks resolve to the same GPU UUID.

The probe is a required gate before retrying the V3 formal train after the
node-specific OOM documented in `../v3_native_pour_boundary_upweight/INFRA_OOM_20260722_104800.md`.
