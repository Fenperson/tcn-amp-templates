# Repository instructions

This repository contains public custom AMP Generic Module templates for The
Cantina Network.

## Scope

- `main` is the canonical, human-maintained source branch.
- Keep each template root and every file it references together under
  `templates/<template-name>/`.
- The `amp` branch is a generated flat deployment artifact because ADS only
  indexes top-level KVP files. Never edit template behavior directly on that
  branch.
- Treat `Meta.AppConfigId` as the stable application identity. Never reuse an
  upstream or another template's identifier.
- Increase `Meta.ConfigVersion` for every published behavioral change.
- Keep release notes factual and specific.
- Never add credentials, protected launch values, private endpoints, runtime
  state, Wine prefixes, game binaries, backups, or logs.

## Required checks

Run before publication:

```powershell
pwsh -NoProfile -File tools/validate-templates.ps1
```

Generate the flat artifact into a new empty path with
`tools/build-amp-artifact.ps1`, compare it with the proposed `amp` branch, and
publish the exact validated bytes. ADS tracks
`Fenperson/tcn-amp-templates:amp`, not `main`.

For live rollout, fetch the `amp` branch in ADS, use a new canary instance,
preserve the old instance as rollback, and verify managed update, process,
ports, stop/start persistence, and application-specific acceptance before
retiring anything.

## Project memory

- `docs/project-state.md`: current source and deployment checkpoint.
- `docs/known-issues.md`: unresolved template and rollout risks.
- `docs/change-log.md`: chronological changes and verification.
- `docs/architecture.md`: repository-to-ADS data flow.
- `docs/security.md`: secret and runtime boundaries.
- `docs/deployment.md`: safe publication and ADS rollout.
- `docs/test-plan.md`: static and live acceptance layers.
