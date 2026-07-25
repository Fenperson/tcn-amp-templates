# Project state

Last verified: 2026-07-25.

## Current state

- Repository source contains custom AMP Generic Module templates for Angels
  Fall First and The Riftbreaker.
- Angels Fall First template version 5 uses unique application identity
  `0135a343-dbe9-43ca-93a4-acf0cf01a844`, Steam dedicated-server app `407480`,
  and `cubecoders/ampbase:wine-stable`.
- Static validation covers both template roots, referenced JSON manifests,
  unique identifiers, versions, required launch fields, and common embedded
  secret patterns.
- The public repository is
  `https://github.com/Fenperson/tcn-amp-templates`. Exact commit
  `0265f569ff61fb9c4df3f50b34c796caf85eab89` passed the local validator and is
  pushed on `main`.
- Root repository-manifest merge
  `ecf14e3f2de02917b6ae7b2902a3d4a859d5afcd` made Angels Fall First and The
  Riftbreaker indexable as distinct named AMP applications. The validator
  accepted the manifest and both templates.
- A repository-created Angels Fall First canary passed pristine Steam app
  install, conditional configuration seeding, Wine-prefix initialization,
  effective-setting/process readback, game/query listener checks, and clean
  stop-start-stop persistence. Exact host details remain in the private TCN
  operating record.
- The current live AFF service remains on compatibility instance
  `ChivalryMedievalWarfare01` and is not to be retired until a
  repository-created canary passes external browser/client acceptance.
- Public server-browser discovery and a real external-client join against the
  new canary remain pending. Exact live rollout state is retained in the
  private TCN operating record.

## Next safe step

Keep the working compatibility instance unchanged. Start the repository-created
canary only for a bounded public browser-discovery and real-client join test,
then stop it again. Do not retire the compatibility instance until that final
acceptance gate passes.
