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
- The current live AFF service remains on compatibility instance
  `ChivalryMedievalWarfare01` and is not to be retired until a
  repository-created canary passes acceptance.
- Repository-backed canary acceptance remains pending. Exact live rollout
  state is retained in the private TCN operating record.

## Next safe step

In an approved authenticated ADS session, create a separate instance from the
repository's **Angels Fall First** entry with start-on-boot disabled and unused
ports. Then execute the canary section of `test-plan.md` without changing or
retiring the working compatibility instance.
