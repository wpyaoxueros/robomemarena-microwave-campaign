# Archived Original-Snapshot Two-GPU Replays

This lane replays the files saved by the original successful exact20 outputs,
not a later file at the same source pathname.

## Why This Exists

The first July 25 archived replay loaded the live historical source directory.
For Task2 and Task18 that was not byte-identical to the files that produced the
original success:

| Component | Original saved snapshot | Later live source |
| --- | --- | --- |
| Task2/3/12/13/18/25/26 launcher | `11aba57fac364c8e9fc9f430c44edf7677defcdd00982667b75e07f98cc9cebd` | `b02956ea062b13dfecef3900d9e9666f633717d77aef8b828d933ebb6c4dcf22` |
| Task2 evaluator | `cda4a23bf018f0c9e4ecb8bc6438d08fbfc6c7be92ebe655751604833dfe3ed4` | `ef95604ca17c7900eac172d0e082a3738ca5b62e8468bf4f53c522590ff7dd2b` |
| Task3/12/13/18/25/26 evaluator | `5a927406c3dd90e0ba833950e6456f88beb2cf28f8adc2707f1f2f8fdb67643b` | `ef95604ca17c7900eac172d0e082a3738ca5b62e8468bf4f53c522590ff7dd2b` |

The later Task2 launcher introduced a runtime end-pose hold/release seen at
`t=303`; the original successful Task2 trace has no such event. Therefore the
live-source Task2/Task18 replays are excluded before any rate comparison.

## Frozen Inputs

`materialize_archived_original_execution_pack.py` copies each task's archived
`code_snapshot` and `repro_snapshot/files` into a job-local execution pack and
verifies every copied file SHA256. It also reconstructs the original relative
directory of the archived base evaluator:

```text
RoboMemArena/evaluation_benchmark/reference_evaluation/
  tasks2_26_vlm5_reference/eval_tasks2_26_vlm_vla.py
RoboMemArena/evaluation_benchmark/openpi_minimal_runtime/*.py
```

This hierarchy is required because the unchanged base evaluator derives its
runtime-module directory relative to `__file__`. A previous flat-copy attempt
(`437181` / `437179`) failed before episode zero with
`ModuleNotFoundError: retry_tasks2_26_stage_from_anygrasp`; it is excluded.
The corrected pack preserves the archived base evaluator byte-for-byte and
copies the matching original runtime modules with recorded SHA256 hashes.

The two-GPU runner uses only that pack for:

- launcher and evaluator;
- base evaluator and task config;
- end-pose target and passage-count files;
- official stage scripts and BDDL files.

The only adapter behavior is replacing obsolete absolute source locations with
the equivalent job-local frozen files while preserving their original relative
layout. It does not edit the copied files, modify rollout parameters, replace
the VLA/VLM checkpoint, or change the first-visible VLA / second-visible VLM
GPU binding.

## Task Mapping

| Task | Archived source output |
| ---: | --- |
| 2 | `/data/user/zzhang510/hlei573_borrow_outputs/repro20_official66e789_task2bddlfix_20260704_1827/task2` |
| 3, 12, 13, 18, 25, 26 | `/data/user/zzhang510/hlei573_borrow_outputs/repro20_official66e789_20260704_1815/task<TASK_ID>` |

Task1 is separate: its saved runner and evaluator SHA256 already equal the
source files currently used by job `437154`, so it remains a valid direct
historical run without the snapshot adapter.

## Submission Contract

Use `probe_and_submit_archived_original_snapshot_topology.sh TASK_ID` from the
actual borrowed-account shell. It performs fresh one-GPU and two-GPU probes in
`acd_u`, `acd_ue`, then `emergency_acd`, and starts the formal 20-episode run
inside tmux only after the exact two-GPU shape passes.
