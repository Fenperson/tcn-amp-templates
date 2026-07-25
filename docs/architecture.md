# Architecture

```text
GitHub main branch (canonical source)
    -> templates/angels-fall-first/
    -> templates/riftbreaker/
        -> validated flattening
            -> GitHub amp branch (generated artifact)
    -> ADS configuration-repository fetch
        -> named Generic Module template
            -> AMP instance-local GenericModule.kvp and manifests
                -> managed SteamCMD/config/Wine update stages
                    -> game process
```

The per-template directories on `main` are the source of truth. Each directory
owns one KVP and every file referenced by that template. The `amp` branch is a
generated, intentionally flat deployment artifact because ADS only indexes
top-level KVP files. ADS fetches `amp` and copies the selected template into
each instance.

Game binaries, Wine prefixes, effective runtime configuration, logs, and
backups remain on AMP01 and never belong in this repository.

Root `manifest.json` gives the repository a unique identity and declares its
`AppTemplates` type. The build copies it to the deployment artifact, where ADS
requires it to index the KVP files into the instance-creation application list.

`Meta.AppConfigId` identifies a template independently from its display name.
`Meta.ConfigVersion` orders intentional releases of that identity. A new AFF
deployment must be created from the repository entry so ADS does not retain
the upstream Chivalry application lineage.
