# Architecture

```text
GitHub main branch
    -> ADS configuration-repository fetch
        -> named Generic Module template
            -> AMP instance-local GenericModule.kvp and manifests
                -> managed SteamCMD/config/Wine update stages
                    -> game process
```

GitHub is the source of truth for template definitions. ADS fetches the
repository and copies the selected template into each instance. Game binaries,
Wine prefixes, effective runtime configuration, logs, and backups remain on
AMP01 and never belong in this repository.

`Meta.AppConfigId` identifies a template independently from its display name.
`Meta.ConfigVersion` orders intentional releases of that identity. A new AFF
deployment must be created from the repository entry so ADS does not retain
the upstream Chivalry application lineage.
