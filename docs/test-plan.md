# Test plan

## Static source

- Exactly one KVP exists in each `templates/<name>/` directory, and the
  directory and KVP names match.
- KVP syntax is parseable.
- Referenced JSON files exist beside their owning KVP and parse.
- Application identifiers and config roots are unique.
- Template versions are positive integers.
- Required launch fields are present.
- No credentials or runtime state are committed.
- Canonical runtime filenames do not collide when flattened.
- No deployable template files exist at `main` repository root.
- A generated flat artifact passes the same KVP/reference checks.

## ADS fetch

- Repository fetch succeeds from the exact published `amp` revision.
- Root `manifest.json` parses, has a unique non-empty identifier, and declares
  `repotype` as `AppTemplates`.
- Angels Fall First and The Riftbreaker appear as distinct named templates.
- AFF shows version 5 and its unique application identifier.

## AFF canary

- Instance is created with a non-Chivalry internal identifier.
- `wine-stable`, app `407480`, base directory, executable, and working
  directory match the repository source.
- Managed update downloads/validates the app, seeds `Config/AMP`, and
  initializes the Wine prefix.
- AMP reports the application running.
- The AFF process is present without printing protected command-line values.
- Game, adjacent-auth, and query UDP ports listen.
- Stop and start preserve the template and effective settings.
- Browser discovery and an external-client join pass before migration is
  declared complete.

### 2026-07-25 result

- Passed: distinct non-Chivalry instance creation, `wine-stable`, Steam app
  `407480`, pristine managed update, conditional `Config/AMP` seeding, Wine
  initialization, application start, safe process readback, game/query UDP
  listeners, effective-setting persistence, and clean stop-start-stop.
- Pending: public server-browser discovery, a real external-client join, and
  separate confirmation of any adjacent authentication listener expected by
  the final production port layout.
- The compatibility instance remained running and recoverable throughout.

## Rollback

- The former live instance remains unchanged and recoverable throughout the
  canary.
- A failed canary is stopped and investigated; it does not replace the working
  instance automatically.
