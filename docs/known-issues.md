# Known issues

## Hosted validation workflow is not published

The current GitHub CLI authorization can push repository content but cannot
create or update `.github/workflows/` without an additional workflow scope.
Run the checked-in validator and artifact builder locally for every
publication. Review and publish the generated `amp` branch separately until a
separately reviewed authorization change permits hosted CI.

## Deployment branch publication is manual

`main` is the only editable source of truth; ADS consumes the generated flat
`amp` branch. Until a reviewed hosted workflow exists, publication requires a
local build, byte-for-byte artifact review, and a separate deployment-branch
commit. Never patch template behavior directly on `amp`.

## Angels Fall First compatibility-instance lineage

The legacy deployment lineage originated as
`ChivalryMedievalWarfare01`. An AMP template/module refresh can therefore load
CubeCoders' upstream Chivalry definition and restore obsolete
`chivalrymw/220070` launch paths.

Do not assume that compatibility instance remains available as rollback;
current instance presence is recorded privately. Any recreated instance must
come from this repository's named AFF template and pass browser discovery plus
a real external-client join before production use. Managed update, pristine
seeding, process and game/query-port readback, and stop/start persistence have
previously passed.

## AFF external-client acceptance remains pending

The repository-backed canary previously passed first install and lifecycle
acceptance. Complete browser-discovery and external-client checks against any
retained or recreated canary before production use.

## Steam client-ticket authentication under Wine

The tested AFF Wine route requires client-ticket authentication disabled.
This weakens Steam identity assurance and is not solved by repository
publication.

## Riftbreaker public acceptance

The Riftbreaker template has separate public-networking and Steam-enabled
launch gates documented in the TCN coordination workspace. Repository
publication does not close those gates.
