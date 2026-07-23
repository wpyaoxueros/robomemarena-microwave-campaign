# v122 Attempt 20260722 073155: Infrastructure Failure

## Scope

This attempt started the two pre-registered one-episode runs for seeds `104`
and `107` from the frozen v122 entry point.

## Outcome

Both Slurm allocations exited before loading either model or creating an
episode. The entry point rejected the untracked private inputs file because
the enclosing private-input directory did not grant the submitting `irpn`
group read/traverse access.

This is not an evaluation result and contributes no numerator or denominator
to the v122 reproduction score.

## Evidence

- Seed 104 allocation: exited with the explicit preflight message
  `missing PRIVATE_INPUTS_FILE`.
- Seed 107 allocation: exited with the same explicit preflight message.
- No `summary.tsv`, stage score, goal score, model rollout, or video was
  generated.

## Corrective action

The local-only private input directory was changed from owner-only access to
`hlei573:irpn` group-readable/traversable access. The next invocation uses a
new run identifier and retains the same frozen code commit and scorer.
