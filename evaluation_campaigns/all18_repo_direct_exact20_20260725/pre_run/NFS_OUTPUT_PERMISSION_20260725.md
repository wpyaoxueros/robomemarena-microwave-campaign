# NFS Output Permission Record

## Observation

On 2026-07-25, `zzhang510` could create files under the campaign output test
directory, but `xiangqim` and `prtroas0003` could not. This remained true with
both `irpn:setgid` and `formal:setgid`, and with mode `2777` on the leaf output
directory. The failure is therefore an NFS access-control behavior above the
leaf directory, not a missing group membership: all three users list `irpn` in
their Unix groups.

## Campaign Decision

Each Slurm job writes raw videos and logs under the submitting user's own
`/data/user/<user>/hlei573_borrow_outputs/` directory. The run manifest,
official summary, source hashes, job identity and absolute artifact paths are
then copied into the Git-tracked task result record. This avoids pretending a
shared output directory is writable when it is not.

## Validation Required Before Each Launch

From the submitting account's shell, verify:

1. Read access to the tracked launcher, VLA norm and task VLM checkpoint.
2. Write access to that account's selected output root.
3. A fresh 1-GPU no-account Slurm probe from the same shell.
