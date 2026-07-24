# RoboMemArena Reproduction Campaign

This is the single monorepo for the Task20--Task24 microwave reproduction
campaign and the Task14 drawer baseline. Every frozen task version lives below
`tasks/` or `task14/versions/`; each run keeps its evaluator, configuration,
launcher and result record in the same repository history.

The repository also contains isolated counting snapshots below `counting/`.
They remain separate from the microwave task versions but use the same
reproducibility conventions. `counting/task7_vlm35999_latest_d9f83ac_hardcase500_20260724`
records the Task7 8ep autonomous result (4/8 stage successes).
`counting/task16_vlm35999_d9f83ac_pourreturnassist_20260724` records the
Task16 VLM-prompted rotation-return controller-assisted success separately.

No checkpoint, raw video, debug image, credential, or absolute local path is
committed here. Source repositories have been imported with their Git history
preserved; they remain read-only historical references and are no longer the
destination for new versions.
