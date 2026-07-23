# Task14 v1 Latest-Score Baseline

Task14 places cookies in the top drawer and chocolate in the middle drawer.
This frozen baseline uses VLM prompts plus VLA `35999`, with RoboMemArena
commit `d9f83ac5182e25ad7f0a301a77a0b667f2392df1` and its stage scorer.

The recorded 20 seeds (104--123) produced average stage score `42.0%` and
full stage/goal success `2/20 = 10%`. It is a reproducible baseline, not a
claim of stable Task14 success.

## Run

```bash
set -a
source .env
set +a

CUDA_VISIBLE_DEVICES=0,1 NUM_TRIALS=1 SEED=104 bash scripts/run_task14_v1.sh
CUDA_VISIBLE_DEVICES=0,1 NUM_TRIALS=20 SEED=104 bash scripts/run_task14_v1.sh
```

Run `scripts/bootstrap_robomemarena.sh <checkout-dir>` first, then provide
local model paths in the untracked `.env`. No checkpoint, training data, raw
video or absolute local path is committed.

## Autonomy Contract

All `ORACLE_*` prompt switches are fixed to zero. The VLM selects primitive
prompts; EEF hold/release and regression guards only control timing. The
package fails instead of falling back when the official stage file is absent.
