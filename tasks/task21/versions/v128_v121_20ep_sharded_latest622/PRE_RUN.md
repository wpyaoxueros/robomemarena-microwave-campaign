# Task21 V128: V121 20-Episode Sharded Reproduction

V128 is the formal 20-episode form of the successful V127 serial condition.
It launches five independent two-GPU workers. Each worker keeps one VLA server
resident and evaluates four sequential episodes:

| Shard start seed | Episodes |
| ---: | --- |
| 100 | 100-103 |
| 104 | 104-107 |
| 108 | 108-111 |
| 112 | 112-115 |
| 116 | 116-119 |

The only intentional difference from V127 is `NUM_TRIALS=4` per worker. The
VLM still supplies all task prompts. All oracle prompt flags remain zero. The
robot-only empty release-anchor interface, EEF hold/release settings, V121
tolerances, current remote scorer, and optional-close stage policy are kept.

Every worker writes an immutable evaluator snapshot. `aggregate_20ep.py` rejects
missing, duplicate, or non-contiguous seeds before reporting a 20-episode rate.
Checkpoint paths are supplied through an ignored private input file and are not
written in this repository.
