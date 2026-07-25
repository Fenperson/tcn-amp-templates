# TCN AMP templates

Version-controlled custom AMP Generic Module templates maintained for The
Cantina Network.

The root `manifest.json` identifies this repository to ADS as an
`AppTemplates` source. ADS may clone a configuration repository but omit all
of its applications when this manifest is absent.

## Templates

### Angels Fall First

- Template root: `angels-fall-first.kvp`
- Settings manifest: `angels-fall-firstconfig.json`
- Metaconfig manifest: `angels-fall-firstmetaconfig.json`
- Steam dedicated-server app: `407480`
- Runtime: `cubecoders/ampbase:wine-stable`

Create new deployments from the **Angels Fall First** entry supplied by this
repository. Do not convert or module-upgrade an upstream Chivalry instance:
that can restore the upstream `chivalrymw/220070` launch definition.

### The Riftbreaker

- Template root: `riftbreaker.kvp`
- Settings manifest: `riftbreakerconfig.json`
- Metaconfig manifest: `riftbreakermetaconfig.json`
- Update manifest: `riftbreakerupdates.json`
- Launcher: `riftbreaker-launch.sh`

Follow the TCN operating documentation before changing the live AMP01
deployment.

## AMP registration

Add the repository to ADS as:

```text
Fenperson/tcn-amp-templates:main
```

Fetch the repository, then create instances from its named templates. Keep
start-on-boot disabled until the application-specific acceptance checks pass.

## Validation

Run:

```powershell
pwsh -NoProfile -File tools/validate-templates.ps1
```

The validator checks the required repository manifest, JSON syntax, referenced
files, unique application identifiers, positive template versions, and
required launch fields.

## Safety

- Do not store Steam credentials, passwords, tokens, or private endpoints in
  this repository.
- Treat managed **Update** and ADS module/template upgrade as different
  operations.
- Back up the instance definition and effective game configuration before a
  live template migration.
- Preserve the old instance as rollback until the replacement passes lifecycle
  and real-client acceptance.

Current state and operational caveats are recorded under `docs/`.
