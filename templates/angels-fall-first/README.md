# Angels Fall First

Custom AMP Generic Module template for the Angels Fall First dedicated server.

| File | Purpose |
| --- | --- |
| `angels-fall-first.kvp` | Application identity, Wine runtime, update stages, ports, and launch definition |
| `angels-fall-firstconfig.json` | AMP settings exposed to the operator |
| `angels-fall-firstmetaconfig.json` | Mapping from AMP settings into UE3 PCServer configuration |

Key facts:

- Stable AMP application identity:
  `0135a343-dbe9-43ca-93a4-acf0cf01a844`
- Steam dedicated-server app: `407480`
- Linux runtime: `cubecoders/ampbase:wine-stable`
- Current template version: `5`

The repository-created canary passed pristine install, conditional
configuration seeding, Wine initialization, settings/process readback,
game/query listeners, and stop-start-stop persistence. Public browser
discovery and a real external-client join against that canary remain pending.

Do not module-upgrade an upstream Chivalry-derived compatibility instance. Use
this named template for new AFF instances.
