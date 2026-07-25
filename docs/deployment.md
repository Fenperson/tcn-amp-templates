# Deployment

## Publish

1. Run `pwsh -NoProfile -File tools/validate-templates.ps1`.
2. Review the exact diff and template-version changes.
3. Commit and push `main`.
4. Record the validator result for the exact pushed commit. A hosted workflow
   may be added later when GitHub authorization includes workflow scope.

## Register in ADS

1. Preserve a scoped backup of the affected instance and effective game
   configuration.
2. Add `Fenperson/tcn-amp-templates:main` to ADS configuration repositories.
3. Fetch the repository and confirm both named templates appear.
4. Do not press a module-upgrade control on a compatibility instance.

## Canary rollout

1. Create a new instance from the named custom template.
2. Use an independent instance identifier and unused ports.
3. Keep start-on-boot disabled.
4. Run managed **Update** and verify every update stage.
5. Apply the reviewed application settings.
6. Run the checks in `test-plan.md`.
7. Keep the former instance stopped but recoverable until real-client
   acceptance passes.

Deletion of a former instance is a separate operator-approved action.
