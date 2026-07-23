# Rejected v3 Data Build: copies=32

The builder completed successfully with the following audit values:

- Base rows: 326,500
- Canonical native first-pour boundary rows: 11,100
- Added rows at `copies=32`: 355,200
- Output rows: 681,700
- Base SHA-256: `4267075175876b9d40a1557a9cb77114289365aa02762cd38f21de14651d3803`
- Output SHA-256: `d3fa4ea6dac388e32dde57f2d54142f1c1324403b59d5d603805321a2ca3eeda`

This build is structurally valid but rejected before VLM training because it
would more than double the dataset.  It is retained only as a private audit
artifact.  The accepted v3 build uses `copies=4`, adding 44,400 rows instead.
