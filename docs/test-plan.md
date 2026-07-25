# Test plan

## Static source

- KVP syntax is parseable.
- Referenced JSON files exist and parse.
- Application identifiers and config roots are unique.
- Template versions are positive integers.
- Required launch fields are present.
- No credentials or runtime state are committed.

## ADS fetch

- Repository fetch succeeds for the exact published revision.
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

## Rollback

- The former live instance remains unchanged and recoverable throughout the
  canary.
- A failed canary is stopped and investigated; it does not replace the working
  instance automatically.
