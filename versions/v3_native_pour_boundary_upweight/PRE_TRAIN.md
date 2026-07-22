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
