# VLA35999 八任务成功复现包

本目录保存原始总包 `repro20_remote_metrics_20260704_175011` 的逐文件复制，用于统一归档此前的 VLA35999 成功/最佳复现实验代码和结果记录。

## 覆盖范围

- 任务：Task1、Task2、Task3、Task12、Task13、Task18、Task25、Task26。
- VLA：原始 fullvlm-v2 noflip checkpoint `35999`。
- 原始官方评分提交：`66e7894f8188be8114911e5df0f8bf89fe4581ce`。
- 原始运行口径：每任务 20 episode，seed `104--123`。

包内保留原来的 `README.md`、`OFFICIAL_RUN_MANIFEST.md`、各任务 code snapshot、evaluator、远端源码快照与结果路径。这里不改写历史成功率；需要最新远端评分口径时，必须从这个包另起一次新 run 并保存新的 manifest。

`SOURCE_COPY_SHA256SUMS.txt` 是此处复制后的文件完整性清单。复制时未带入嵌套 `.git`，微波炉 campaign 仓库的 commit 是后续唯一 Git 历史。
