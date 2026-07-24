# Task7 Counting Reproduction Snapshot

This is the frozen Task7 counting success snapshot in the shared campaign
repository. It stores executable evaluator/training code, result metadata and
the eight official episode outcomes. Checkpoints, raw videos, machine-local
paths and credentials are intentionally excluded.

## Frozen Contract

- Source counting repository:
  `https://github.com/wpyaoxueros/robomemarena-counting-vlm35999-latest-repro.git`
- Source package commit used by the 8ep run: `6c9307ea604deeaa7d489d2ec630a2907a081d67`
- Remote RoboMemArena scorer: `d9f83ac5182e25ad7f0a301a77a0b667f2392df1`
- VLA: original fullvlm-v2 `35999` with matched norm SHA
  `4f71f864b3d34e3b58616d5c01b5efa86e57b317e014a091f62f9ef13ba67a8a`
- VLM: runtime-aligned Task7 hard-case continuation, checkpoint 500.
- Autonomy: `stage_prompt_override=off` and `oracle_prompt_injection=off`.
- Place supervision: disabled. The training data only reinforces real eval
  windows where the VLM must persist on the first pour.

## Official Result

Seeds 100--107: `4/8` full stage successes (50%), average stage score 75%,
goal success rate 75%. See `results.tsv` for the per-episode official stages.
The Task7 target of at least four successes in eight valid episodes is met.

## Reproduction

Set `SOURCE_ROOT`, `OPENPI_ROOT`, `OPENPI_INFERENCE_ROOT`, `VLA_CKPT` and
`VLM_CKPT` to local copies of the recorded assets, then run:

```bash
./run_task7_8ep.sh
```

The launcher refuses to use defaults for checkpoint or source paths. It keeps
the original VLA, the pinned scorer and non-injecting prompt guard contract.
