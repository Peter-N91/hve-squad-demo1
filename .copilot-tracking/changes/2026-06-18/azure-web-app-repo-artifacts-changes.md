<!-- markdownlint-disable-file -->
# Release Changes: Azure Web App Repo Artifacts

**Related Plan**: azure-web-app-repo-artifacts-plan.instructions.md
**Implementation Date**: 2026-06-18

## Summary

Created the approved repo-only documentation package, the validation-only GitHub workflow, and the compile-safe `infra/bicep/` artifact set for the West Europe Azure internal web app baseline. The implementation stops before any Azure login, deployment, or subscription mutation.

## Changes

### Added

* docs/architecture/azure-internal-webapp.md - Captures the approved West Europe architecture, trust boundaries, and council condition mapping.
* docs/architecture/adr-app-service-over-containers.md - Records App Service as the default compute choice over container hosting.
* docs/security/azure-baseline.md - Translates council conditions into security and governance controls.
* docs/security/access-model.md - Defines the identity, RBAC, and approval boundaries.
* docs/operations/azure-webapp-runbook.md - Provides day-0 and day-2 operational guidance with the no-deploy boundary.
* docs/operations/troubleshooting.md - Provides symptom-based troubleshooting guidance for future operations.
* .github/workflows/validate-azure-artifacts.yml - Adds a validation-only workflow with explicit permissions, credential-safe checkout, markdown checks, and conditional Bicep compilation.
* infra/bicep/main.bicep - Adds the Bicep orchestration entrypoint for the approved West Europe artifact set.
* infra/bicep/types.bicep - Adds shared Bicep types and defaults for compile-only validation.
* infra/bicep/README.md - Documents validation-only IaC usage and the no-deploy boundary.
* infra/bicep/environments/westeurope-internal.bicepparam - Adds the West Europe parameter set for compile-only review.
* infra/bicep/modules/networking.bicep - Adds the networking module for the approved private data-plane shape.
* infra/bicep/modules/app-service.bicep - Adds the App Service module for the frontend and backend web apps.
* infra/bicep/modules/sql.bicep - Adds the Azure SQL module with private connectivity.
* infra/bicep/modules/storage.bicep - Adds the Storage module with private connectivity.
* infra/bicep/modules/key-vault.bicep - Adds the Key Vault module with the policy-controlled privacy toggle.
* infra/bicep/modules/monitoring.bicep - Adds the monitoring module for diagnostics and alerts.
* infra/bicep/modules/governance.bicep - Adds the governance module for tags, budget controls, and locks.

### Modified

* .github/workflows/validate-azure-artifacts.yml - Strengthens the no-deploy boundary by failing if Azure login, deploy, or subscription-mutating command patterns are introduced.

### Removed

* None.

## Additional or Deviating Changes

* The workflow remains validation-only even though `infra/bicep/` now exists.
  * The workflow compiles templates and parameter files, but it still blocks Azure login, deployment, and subscription-mutating command patterns.

## Release Summary

Added repo artifacts for architecture, security, operations, compile-safe IaC, and CI validation. No deployment scripts, Azure login steps, secrets handling, or subscription-affecting commands were added. The package remains ready for human review at the no-deploy boundary.
