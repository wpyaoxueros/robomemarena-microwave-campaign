# Clean Legacy Replay Retry Started

This is the first valid behavioral replay attempt after commit `0976500` fixed
the pre-evaluation verification assertion. It retains the recovered legacy
runtime, seed104, one-episode contract, asynchronous VLM settings, model inputs,
and norm identity from `PRE_RUN.md`.

The previous `430911` attempt remains excluded because it never reached policy
server startup. This retry is the candidate result for legacy reproduction.
