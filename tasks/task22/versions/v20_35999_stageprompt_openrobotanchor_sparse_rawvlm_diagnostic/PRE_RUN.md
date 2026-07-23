# Task22 v20 Pre-Run Record

## Evidence From v19

Both v19 attempts reached the real tomato-lift stage, then aborted around
`t=500` before the open-microwave anchor. Their VLA/VLM/scorer code and inputs
matched v18; the common remaining expensive operation was raw VLM inference at
every ten-step VLA replan.

## Single Change

Set `TASK22_STAGEPROMPT_RAW_VLM_INTERVAL=50`. The evaluator caches the last
raw VLM label between refreshes, but the diagnostic stage schedule still
selects the VLA prompt and VLA still replans every 10 actions.

## Non-Goal

This is still a physical-capability diagnostic, not autonomous VLM success. It
adds no prompt oracle beyond the existing stage schedule and does not modify
objects, microwave state, remote scoring, VLA weights, or norm assets.
