# Task24 v131 Fixed-Seed Worker1 Replacement

This is a scheduler-only replacement for the slow `v136` worker1 allocation on
`ACD1-11`. Its VLA inference sustained roughly 20 seconds per five-step chunk,
where the other worker allocations sustained about one second after warm-up.

The replacement runs four independent Task24 episodes with `seed=108`, the same
frozen v131 runtime, autonomous VLM prompt policy, norm fallback route, and
official scorer. The only scheduler difference is `--exclude=ACD1-11`.

The cancelled v136 worker1 partial attempt is retained as infrastructure
evidence and is not included in the final 20-attempt aggregate. Combine this
worker's four valid rows with v136 workers 0, 2, 3, and 4.
