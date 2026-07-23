# Task22 v11: Port-Checked Historical-Node Replay

v11 reuses the exact v8 original runtime and the v10 queued allocation shape.
The only launcher-level correction is an allocation-local reservation check for
port `18722`, selected after verifying it was free on ACD1-6.

The port is local transport only: evaluator, VLM, VLA inputs, seed, scorer,
and prompt logic remain unchanged. No oracle prompt injection is used.
