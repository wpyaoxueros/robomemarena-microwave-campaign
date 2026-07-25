# Central Evidence Registry Design

## Goal

Make every borrowed-account training or evaluation run readable, discoverable,
and reproducible from the owner workspace without relying on chat history,
private home-directory traversal, or manually remembered paths.

## Storage Model

The canonical evidence root is:

```text
/data/user/hlei573/vla_memory_experiments/repro_eval_packs/<campaign>/runs/<run_id>
```

Borrowed-account home directories may be used for caches or disposable staging,
but they are never the canonical source for status, metrics, videos, or
reproduction metadata.

All canonical roots use group `irpn`, the setgid directory bit, and a job umask
of `0007`. Account home directories keep their historical owner, group, and
mode; this mechanism must not recursively alter sibling projects belonging to
other collaborators.

## Launch Gate

Every launcher must run a preflight from the actual submitting account before
requesting the long Slurm allocation. The preflight verifies:

1. `whoami` matches the declared submit user.
2. The evaluator, VLA checkpoint, VLM checkpoint, norm asset, dataset, and
   scoring script are readable.
3. The canonical run directory can be created, written, renamed, and read back.
4. The run directory resolves under the canonical owner-side evidence root.
5. The scorer commit and required scoring-file hash match the declared values.
6. No required asset was selected through fallback behavior.

Any failed check exits nonzero before evaluation or training starts.

## Run Manifest

Each run writes `run_manifest.json` before the Slurm workload begins. It records:

- schema version, run ID, campaign ID, task ID, creation time, and status;
- submit user, Slurm account, partition, job ID, node, and GPU allocation;
- episode count, environment seed, policy seed, replan interval, and stop rule;
- VLA and VLM checkpoint paths, asset IDs, norm paths, and cached hashes;
- evaluator repository path, Git commit, dirty-state marker, launcher command,
  environment variables, and code-snapshot path;
- scoring repository commit, scoring-file path, and scoring-file hash;
- dataset and BDDL paths;
- log, summary, episode table, prompt trace, main video, wrist video, and debug
  artifact locations.

Large immutable checkpoint hashes are computed once and cached in an asset
registry. Per-run manifests reference the cached record and verify stable file
identity instead of rehashing the checkpoint for every episode.

## Registry

The campaign root contains:

```text
RUN_REGISTRY.jsonl
RUN_REGISTRY.tsv
ASSET_REGISTRY.json
```

`RUN_REGISTRY.jsonl` is authoritative and append-only. One record is written at
run creation and another at each state transition: `prepared`, `submitted`,
`running`, `episode_complete`, `completed`, or `failed`.

`RUN_REGISTRY.tsv` is a generated human-readable projection. It includes the
task, run ID, submit user, job ID, completed episodes, successes, scorer commit,
checkpoint asset IDs, status, canonical run directory, summary path, and video
directory.

Concurrent workers never share an output directory. Registry updates use a
short file lock and atomic rename; workers do not hold the lock during rollout.

## Runtime Evidence

Critical evidence is written directly to the canonical run directory:

- manifest and preflight report;
- stdout/stderr and evaluator logs;
- per-episode status and final summary;
- prompt trace and scorer output;
- code snapshot and exact command.

Videos are written using the evaluator's normal episode-level behavior. The
launcher must not produce per-step loose image files unless the run explicitly
enables debug capture. Debug frames, when required, are packed after the episode
instead of causing sustained small-file traffic.

Git commit, Git push, full-directory checksums, and remote synchronization run
only after a batch or run finishes. They are never part of the rollout hot path.

## Reporting Contract

A result may be reported as verified only when:

1. its canonical run directory is readable from `hlei573`;
2. its manifest passes schema and path validation;
3. its episode count and success count can be recomputed from saved logs or
   summary files;
4. its evaluator and scoring snapshots match the recorded hashes;
5. its checkpoint and norm identities resolve through the asset registry.

If these checks fail, the status is `unverified`; it must not be described as
stopped, completed, successful, or reproducible.

Borrowed-account `squeue` state is still checked from the submitting account's
own shell. The central registry records that observation but does not replace
the account-side Slurm visibility rule.

## Performance Constraints

All current account output roots and the canonical owner root reside on the
same NFSv4 filesystem, `10.120.48.12:/LK02`, mounted at `/data`. Moving the
canonical path therefore does not introduce a new storage device or network
hop.

The implementation must preserve rollout throughput by:

- updating the registry only at lifecycle boundaries, not every simulation
  step;
- isolating worker directories to avoid lock contention;
- caching large asset hashes;
- avoiding real-time Git operations and recursive synchronization;
- avoiding unbounded per-step debug-frame output.

## Migration

Existing borrowed-account results are not silently treated as canonical. A
migration command imports one historical run at a time, records its source
path, validates readable evidence, writes a manifest, and marks missing fields
explicitly. It copies evidence only after validation and never deletes the
source.

No account-home permission normalization is part of migration. Account roots
are restored separately to their historical modes, and unrelated sibling
directories remain untouched.

## Acceptance Criteria

The mechanism is accepted when test runs from `zzhang510`, `xiangqim`, and
`prtroas0003` each satisfy all of the following:

- preflight passes from the actual borrowed shell;
- the canonical run directory is immediately readable by `hlei573`;
- manifest and registry records contain the exact task, checkpoints, norm,
  scorer, command, Slurm identity, and evidence paths;
- a completed episode is discoverable by task ID without scanning borrowed
  homes;
- manifest validation detects a missing scorer, wrong norm, unreadable output,
  or fallback asset and refuses launch;
- registry and manifest work adds no per-step filesystem writes and no
  measurable rollout slowdown beyond normal run-to-run variance.
