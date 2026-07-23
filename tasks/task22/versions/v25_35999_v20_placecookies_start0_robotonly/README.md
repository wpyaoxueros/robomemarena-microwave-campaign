# Task22 v25: V24 Place-Cookies Start-0 Robot Anchor

v25 preserves the v24 evaluator/runtime/action path byte-for-byte. The only
rollout change is one additional robot/gripper-only initial anchor when the
stage schedule switches to `place cookies`:

- HDF: `place_cookies_6_seed104_task22.hdf5`
- frame: `0`
- state applied: robot joints and gripper only

Frame 0 is the first state of the original `place cookies` trajectory: the
gripper is closed and the recorded action is still a close/keep-grasp action.
It places the EEF at the post-pick transport pose while leaving every object,
microwave joint, and stage state in the live environment unchanged.

## Frozen Inputs

- VLA: original `35999` checkpoint and its built-in norm asset.
- Remote scorer: `8b7710924f862ab1c8dea69adada62e8c462de40`.
- VLM raw observation interval: `50`; VLA replan: `10`.
- Existing v20 `open microwave` anchor and v24 `pick cookies` pregrasp-160
  anchor remain unchanged.
- No object anchor, goal override, completed-task field, or oracle next prompt.
- This remains a stage-scheduled physical diagnostic, not VLM-autonomous success.
