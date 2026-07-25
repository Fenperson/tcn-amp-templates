# Template source catalogue

Each directory is one independent AMP Generic Module template and contains all
of that template's editable source files.

| Application | Directory | Stable application identity |
| --- | --- | --- |
| Angels Fall First | [`angels-fall-first/`](angels-fall-first/) | `0135a343-dbe9-43ca-93a4-acf0cf01a844` |
| The Riftbreaker | [`riftbreaker/`](riftbreaker/) | `fc9e6dc1-5e6a-4100-b2af-8031bfe1185d` |

Do not add deployable KVP or companion files directly to repository root.
`tools/build-amp-artifact.ps1` flattens these directories for the generated
`amp` branch and fails if filenames collide.
