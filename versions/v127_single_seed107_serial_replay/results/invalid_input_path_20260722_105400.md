# Task21 v127 Invalid Submission: Missing Private Input Mapping

The first v127 submission allocated a node but exited before launching the
evaluator because the caller supplied a nonexistent private input file. The
job emitted `missing private inputs`, wrote no rollout log, summary, scorer
output, or video, and is invalid.

No tracked v127 code, policy setting, prompt behavior, scorer snapshot, VLM,
or VLA selection changed. The retry must use the same private mapping used by
the valid v126 launcher and keep all v127 behavior unchanged.
