# Change log

## 2026-07-25

- Separated the canonical `main` source into
  `templates/angels-fall-first/` and `templates/riftbreaker/`, each with an
  application-specific README and all files owned by that template.
- Established `amp` as the generated flat deployment branch required by ADS.
  ADS switched from `:main` to `:amp`, fetched the known-good artifact, and
  continued to expose exactly one entry for each application.
- Reworked validation to enforce template-directory ownership, reject
  deployable root files and flattening collisions, and validate a simulated
  flat artifact. Added a fail-closed artifact builder that only writes to a new
  output path.
- Established the existing TCN AMP template directory as a standalone,
  publishable configuration repository.
- Added a deterministic validation command, project memory, deployment
  guidance, and secret-handling boundaries. Hosted workflow publication is
  deferred because the current GitHub CLI authorization lacks workflow scope.
- Bumped Angels Fall First from template version 4 to 5. Version 5 records the
  repository-backed identity correction after an upstream Chivalry template
  replaced the live AFF launch paths.
- Published public repository
  `https://github.com/Fenperson/tcn-amp-templates` and pushed exact commit
  `0265f569ff61fb9c4df3f50b34c796caf85eab89` on `main`.
- Live rollout and canary evidence remain in the private TCN operating record;
  repository acceptance is still pending.
- Added the required root AMP repository `manifest.json`. ADS can clone a
  repository without indexing its applications when this file is absent, so
  validation now fails closed if the manifest or its canonical identity/type
  fields are missing.
- Merged the repository manifest as
  `ecf14e3f2de02917b6ae7b2902a3d4a859d5afcd`. ADS indexed both named
  applications and a repository-created AFF canary passed pristine install,
  conditional configuration seeding, Wine initialization, settings/process
  readback, game/query listeners, and stop-start-stop persistence. Public
  browser discovery and a real external-client join remain pending.
