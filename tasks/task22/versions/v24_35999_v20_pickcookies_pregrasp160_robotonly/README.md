# Task22 v24: V20 Pick-Cookies Pregrasp-160 Robot Anchor

v24 preserves the v20 evaluator/runtime/action path byte-for-byte. The only
rollout change is one additional robot/gripper-only initial anchor when the
stage schedule switches to `pick cookies`:

- HDF: `pick_cookies_5_seed104_task22.hdf5`
- frame: `160`
- state applied: robot joints and gripper only

Frame 160 is immediately before the training trajectory starts closing the
gripper at frame 170. It places the EEF at the cookies grasp pose while keeping
the gripper open and leaves every object, microwave joint, and stage state in
the live environment unchanged.

## Frozen Inputs

- VLA: original `35999` checkpoint and its built-in norm asset.
- Remote scorer: `8b7710924f862ab1c8dea69adada62e8c462de40`.
- VLM raw observation interval: `50`; VLA replan: `10`.
- Existing v20 `open microwave` robot/gripper anchor remains at frame 0.
- No object anchor, goal override, completed-task field, or oracle next prompt.
- This remains a stage-scheduled physical diagnostic, not VLM-autonomous success.
