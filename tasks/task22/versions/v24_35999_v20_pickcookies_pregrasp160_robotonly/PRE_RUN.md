# Task22 v24 Pre-Run Record

## Evidence

Historical v20 completed five of the six required Task22 stages, reaching the
`pick cookies` boundary only after the microwave was open. The frame-0
pick-cookies robot anchor in v21 reached the EEF target but did not preserve a
complete final result because its VLM process aborted before final scoring.

## Single Change From v20

Add a second initial anchor at first `pick cookies` entry, using frame 160 of
the seed-104 training subtask. The selected frame is pregrasp: action gripper
is open (`-1`), while frame 170 is the first close action and is intentionally
excluded. The anchor writes robot joints and gripper only.

All evaluator/runtime files are copied byte-for-byte from v20. The VLA, VLM,
norm, scorer, prompt schedule, raw-VLM interval, open-microwave anchor, and
all non-robot simulation state are unchanged.
