# TCN AMP templates

Version-controlled custom AMP Generic Module templates maintained for The
Cantina Network.

`main` is organized for people: each application has one self-contained source
directory under [`templates/`](templates/README.md). The generated `amp`
branch is organized for ADS, which requires every deployable KVP and referenced
file at repository root.

```text
templates/
├── angels-fall-first/
│   ├── README.md
│   ├── angels-fall-first.kvp
│   ├── angels-fall-firstconfig.json
│   └── angels-fall-firstmetaconfig.json
└── riftbreaker/
    ├── README.md
    ├── riftbreaker.kvp
    ├── riftbreakerconfig.json
    ├── riftbreakermetaconfig.json
    ├── riftbreakerupdates.json
    └── riftbreaker-launch.sh
```

## Template catalogue

| Template | Source | Runtime |
| --- | --- | --- |
| Angels Fall First | [`templates/angels-fall-first/`](templates/angels-fall-first/) | Steam app `407480` in `cubecoders/ampbase:wine-stable` |
| The Riftbreaker | [`templates/riftbreaker/`](templates/riftbreaker/) | Steam app `4114030`; host-native Linux compatibility launcher |

Create AFF deployments from this repository's **Angels Fall First** entry. Do
not convert or module-upgrade an upstream Chivalry instance: that can restore
the upstream `chivalrymw/220070` launch definition.

## AMP registration

Add the repository to ADS as:

```text
Fenperson/tcn-amp-templates:amp
```

The `amp` branch is a flat deployment artifact generated from `main`; it is not
the editable source of truth. Fetch it, then create instances from its named
templates. Keep start-on-boot disabled until the application-specific
acceptance checks pass.

## Validation

Run:

```powershell
pwsh -NoProfile -File tools/validate-templates.ps1
```

The validator checks the required repository manifest, JSON syntax, referenced
files within each template directory, unique application identifiers, positive
template versions, required launch fields, and whether the two directories can
be flattened without collisions.

Build a fresh flat artifact into a path that does not already exist:

```powershell
pwsh -NoProfile -File tools/build-amp-artifact.ps1 -OutputPath <new-path>
```

Publication and ADS procedures are in [`docs/deployment.md`](docs/deployment.md).

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
