# The Riftbreaker

Custom AMP Generic Module template for The Riftbreaker dedicated server.

| File | Purpose |
| --- | --- |
| `riftbreaker.kvp` | Application identity, ports, settings, and launch definition |
| `riftbreakerconfig.json` | AMP settings exposed to the operator |
| `riftbreakermetaconfig.json` | Mapping from AMP settings into runtime configuration |
| `riftbreakerupdates.json` | Managed update and runtime verification stages |
| `riftbreaker-launch.sh` | Host-native Linux compatibility launcher and lifecycle supervisor |

Key facts:

- Stable AMP application identity:
  `fc9e6dc1-5e6a-4100-b2af-8031bfe1185d`
- Steam dedicated-server app: `4114030`
- Linux route: host-native compatibility runtime
- Current template version: `10`

Public-networking, current settings-page readback, and supervisor-only AMP
resource metrics remain acceptance gates in the private TCN operating record.
