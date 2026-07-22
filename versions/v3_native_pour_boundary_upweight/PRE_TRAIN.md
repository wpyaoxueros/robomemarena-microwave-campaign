# Task22 v3 Native First-Pour Boundary Upweight

## Failure Being Addressed

In the valid v2 seed104 rollout, the VLA lifted tomato sauce, but the VLM then
repeatedly selected `place tomato aside` instead of `pour first`.  The runtime
guard deliberately held that invalid forward switch; it did not invent a
replacement prompt.

## Single Data Change

v3 preserves every original Task22 JSONL row byte-for-byte and appends copies
of canonical existing rows satisfying all of the following:

- Task ID is 22.
- Native primitive is `pour_first` / `pour first`.
- The visual window starts at frame 0 of that primitive.
- The source row is the canonical original repeat (`repeat_index=0`).
- The assistant JSON already labels the row as `pour first`.

The image paths and label are preserved.  No generated image, relabelled
example, eval video, runtime prompt override, scorer change, or object anchor
is included.

The initial controlled build uses four extra copies per selected row.  This
keeps the added rows below the size of the original full dataset rather than
allowing the boundary samples to dominate it.

## Reproducibility Contract

- The builder records source/output SHA-256 hashes, selected source QIDs, and
  copy count in a private output manifest.
- Paths and checkpoint selections are supplied through ignored local inputs;
  they are not committed to this repository.
- Before training, commit and push the builder, the manifest, and the exact
  training launcher.  Before evaluation, commit and push the evaluator version
  and result record.
- Any later hard-case augmentation from rollout frames is a separate version;
  it must not be mixed into v3.

## Training Contract

The v3 finetune starts from the same private Task22 VLM checkpoint used by v2,
not from a random base.  It uses the recovered original full-finetune recipe:
two GPUs, frozen vision tower, predictive-coding head enabled, learning rate
`1e-5`, and gradient accumulation `2`.  A one-step batch-4/2 Slurm probe is
recorded before the 500-step run; the largest passing batch is used.  Optimizer
state is not resumed, so the only intended model-input change is the accepted
v3 dataset frequency adjustment.
