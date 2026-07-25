# Known issues

## Hosted validation workflow is not published

The current GitHub CLI authorization can push repository content but cannot
create or update `.github/workflows/` without an additional workflow scope.
Run the checked-in validator locally for every publication until a separately
reviewed authorization change permits hosted CI.

## Angels Fall First compatibility-instance lineage

The current live deployment originated as
`ChivalryMedievalWarfare01`. An AMP template/module refresh can therefore load
CubeCoders' upstream Chivalry definition and restore obsolete
`chivalrymw/220070` launch paths.

Create a new instance from this repository's **Angels Fall First** entry. Keep
the compatibility instance as rollback until the new instance passes managed
update, process and port readback, stop/start persistence, browser discovery,
and a real external-client join.

## Steam client-ticket authentication under Wine

The tested AFF Wine route requires client-ticket authentication disabled.
This weakens Steam identity assurance and is not solved by repository
publication.

## Riftbreaker public acceptance

The Riftbreaker template has separate public-networking and Steam-enabled
launch gates documented in the TCN coordination workspace. Repository
publication does not close those gates.
