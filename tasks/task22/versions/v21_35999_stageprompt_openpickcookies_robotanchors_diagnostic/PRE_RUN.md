# Task22 v21 Pre-Run Record

## Evidence From v20

v20 completed five of six required remote stages under the same 35999 policy,
same VLM, same built-in norm, and scorer commit. The open-microwave
robot/gripper anchor was applied at `t=670`; the remote scorer then marked open
microwave true at `t=966`. From the subsequent `pick cookies` stage to
`t=3000`, `cookies_pick_ready` remained zero.

## Single Change

Keep every v20 setting and add one matching seed-104 training-subtrajectory
robot/gripper pose anchor at first entry to `pick cookies`:

- HDF: `pick_cookies_5_seed104_task22.hdf5`
- frame: `0`
- state written: robot joint positions and gripper positions only

The cookies body, microwave state, stage state, prompt trace, VLA weights,
norm asset, and remote scorer are not modified.

## Interpretation Rule

A six-of-six result establishes that the carry-over robot pose was the missing
physical boundary. It remains a stage-scheduled capability diagnostic, not a
claim of VLM-owned prompt switching.
