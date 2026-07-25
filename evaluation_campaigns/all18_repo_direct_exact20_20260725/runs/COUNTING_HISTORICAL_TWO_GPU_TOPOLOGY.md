# Counting Historical Two-GPU Comparator

This entrypoint replaces the campaign's excluded single-GPU overlays for the
counting tasks that have strong frozen reference results.

## Tasks

| Task | Frozen result used for comparison | Required topology |
| --- | --- | --- |
| 6 | seed100, 17/20 stage success | VLA first visible GPU; VLM/evaluator second visible GPU |
| 16 | seeds100--119, 18/20 stage success | VLA first visible GPU; VLM/evaluator second visible GPU |

Both routes use the original fullvlm-v2 VLA checkpoint `35999`, norm SHA256
`4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`, and
the frozen d9f83ac scorer SHA256
`0ab5e19cb7b90844b86fe04a76facc0364af55f1e841c4754aa675404a318538`.

The comparator fails before rollout unless exactly two GPUs are visible. It
does not build an evaluator overlay, remap both models to one GPU, inject an
oracle prompt, or replace the frozen VLM/VLA/norm paths.

The frozen evaluator imports the official evaluator through
`PACK_DIR/source/RoboMemArena_d9f83ac`. Each run therefore copies the frozen
code into an output-local `execution_pack` and creates only this expected
source-directory symlink to the pinned d9 checkout. The copied Python files
are SHA256-checked against the frozen package before rollout; the symlink is a
path compatibility layer, not an evaluator modification.

## Launch

From a validated borrowed-account shell:

```bash
OUTPUT_ROOT=/data/user/$USER/hlei573_borrow_outputs/all18_repo_direct_exact20_20260725 \
bash evaluation_campaigns/all18_repo_direct_exact20_20260725/scripts/probe_and_submit_counting_historical_two_gpu.sh 6
```

Replace `6` with `16` for Task16. The output manifest records source hashes,
checkpoint paths, visible GPU topology, and the campaign commit.
