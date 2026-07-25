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

The current live deployment originated as
`ChivalryMedievalWarfare01`. An AMP template/module refresh can therefore load
CubeCoders' upstream Chivalry definition and restore obsolete
`chivalrymw/220070` launch paths.

Keep the compatibility instance as rollback until the repository-created
canary passes browser discovery and a real external-client join. Managed
update, pristine seeding, process and game/query-port readback, and stop/start
persistence have passed.

## AFF external-client acceptance remains pending

The repository-backed canary passed first install and lifecycle acceptance.
Complete browser-discovery and external-client checks before replacing the
working deployment.

## Steam client-ticket authentication under Wine

The tested AFF Wine route requires client-ticket authentication disabled.
This weakens Steam identity assurance and is not solved by repository
publication.

## Riftbreaker public acceptance

The Riftbreaker template has separate public-networking and Steam-enabled
launch gates documented in the TCN coordination workspace. Repository
publication does not close those gates.
