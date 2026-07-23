# v145 继承说明

v151 的代码基线是 Task23 v145 Git commit `12c589b`。其中 seed105 的完整视频达到前两个
官方 stage。为保留可追溯性，本目录中的 `PARENT_V145_*` 文件是 v145 的历史记录副本，
不是 v151 的结果。

v151 的唯一评测行为差异见 `HYPOTHESIS.md`：删除 `place popcorn` 的 end-pose target 和
consecutive hold；其余 VLA/VLM、短 primitive prompt、评分与 hold/release 配置保持 v145。
