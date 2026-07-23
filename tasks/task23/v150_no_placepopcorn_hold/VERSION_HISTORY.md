# 版本历史

| 版本 | 继承 | 唯一改动 | prompt 权限 | 评分 | 结果 |
| --- | --- | --- | --- | --- | --- |
| v150 | v149 (`f9b9ae7`) | 从 Task23 hold target 中删除 `place popcorn`，避免浅层 EEF hold | VLM 自主，oracle=0 | RoboMemArena `62214036103ee8d5fef9b475dd8b344b6e2cfc03` | seed104: 0/3 stage；开门未完成，未覆盖 place-popcorn，见 `history/RESULT.md` |

本仓库只表示 v150。下一次配置、模型或评分代码改动必须进入新的仓库，并在该表的后继仓库
中记录 v150 的 commit 作为继承来源。
