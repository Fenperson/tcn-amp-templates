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
- Publication and AMP01 registration are in progress. The current live AFF
  service remains on compatibility instance `ChivalryMedievalWarfare01` and is
  not to be retired until a repository-created canary passes acceptance.

## Next safe step

Publish the exact validated source, register `Fenperson/tcn-amp-templates:main`
in ADS, fetch it, and create a stopped-start-on-boot canary from the repository
entry.
