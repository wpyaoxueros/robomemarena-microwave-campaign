# Task22 v16 Pre-Run Record

## Root-Cause Evidence

v15 proved that the original 35999 policy and built-in norm correctly reach a
real `pick tomato` EEF hold. It also proved that strict next-label release
freezes the visual state: the VLM repeatedly returned `place tomato aside`
while the evaluator required `pour first` and performed no further action.

## Hypothesis

Preserving the VLM-selected prompt until its EEF hold is useful, but requiring
the evaluator to prescribe the exact next label is too restrictive. Releasing
to the VLM's own forward candidate after hold should preserve new observations
and permit subsequent VLM transitions without oracle prompt injection.

## Only Changed Setting

`STRICT_HOLD_RELEASE_NEXT=0`.

All other v15 code, checkpoint fingerprints, built-in norm asset, scorer
commit, VLM checkpoint, EEF tolerances, and disabled oracle/object controls are
unchanged.

## GPU Gate

Before the single seed-104 rollout, run a fresh 1-GPU probe and a fresh 2-GPU
probe from `zzhang510`, then retain logs, stage JSON, prompt trace, EEF
hold/release events, norm-load audit, and videos.
