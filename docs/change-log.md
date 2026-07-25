# Change log

## 2026-07-25

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
