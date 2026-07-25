# Security

- This public repository contains no credentials or private runtime state.
- SteamCMD downloads used by the templates are anonymous unless separately
  reviewed and changed.
- Protected values must use AMP's protected settings and must not be placed in
  Git, process logs, screenshots, or documentation.
- Publication does not make the templates trusted automatically. The checked-in
  validator performs structural checks; live rollout still requires an
  operator-reviewed canary.
- Do not expose additional ports merely because a template declares them.
  Firewall and public reachability remain separate controls.
- The AFF Wine baseline has a documented client-ticket authentication
  exception. Do not claim Steam identity or VAC guarantees for that route.
