---
title: Azure Web App Repo Artifacts Details
description: Step-level implementation details for the no-deploy autopilot artifact sequence after the revised council verdict.
---
<!-- markdownlint-disable-file -->

# Implementation Details: Azure Web App Repo Artifacts

## Context Reference

Sources: .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md, .copilot-tracking/squad/decisions.md, .copilot-tracking/squad/team.md, .github/instructions/bicep.instructions.md, .github/instructions/workflows.instructions.md

## Implementation Phase 1: Research refinements and artifact freeze

<!-- parallelizable: false -->

### Step 1.1: Confirm architecture choices and open policy deltas

Owner: researcher with azure-architect review.

Capture a short architecture note that freezes the selected deployment shape for implementation: West Europe only, two Azure App Service B1 apps with public Entra ID-protected ingress, one VNet with an integration subnet and a private-endpoints subnet, Azure SQL Basic and Storage Standard GRS behind private endpoints, Key Vault with managed identity access, Log Analytics diagnostics, and no containerization. Record the only unresolved policy-sensitive toggle as `keyVaultPrivateEndpoint` with a default of `false` unless the implementer finds an explicit policy requiring it.

Files:
* docs/architecture/azure-internal-webapp.md - Architecture summary and trust boundaries
* docs/architecture/adr-app-service-over-containers.md - Short ADR or decision note for App Service preference

Discrepancy references:
* DD-01

Success criteria:
* The architecture note matches the revised council verdict and accepted constraints
* The Key Vault private-endpoint toggle is explicitly documented as optional and policy-driven

Context references:
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 9-35) - Constraints, chosen architecture, and budget guardrails
* .copilot-tracking/squad/decisions.md (Lines 47-79) - Revised council conditions

Dependencies:
* Revised council Go-With-Conditions verdict

### Step 1.2: Freeze repo artifact map and ownership

Owner: lead, handed to developer and iac-author.

Define the repo artifact map before any implementation work starts so the implementer does not invent structure ad hoc. Use a dedicated `infra/bicep/` tree for IaC, `docs/architecture/`, `docs/security/`, and `docs/operations/` for human-readable assets, and one validation-only workflow under `.github/workflows/`. Assign ownership per artifact in the plan so the handoff is unambiguous.

Files:
* infra/bicep/ - Main IaC root for the future implementation
* docs/architecture/ - Architecture and ADR artifacts
* docs/security/ - Security baseline and governance control notes
* docs/operations/ - Runbook and troubleshooting assets
* .github/workflows/validate-azure-artifacts.yml - Non-deploy validation workflow

Success criteria:
* Every future repo artifact has a target path and owning role
* The file set covers architecture, IaC, security, operations, and validation

Context references:
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 37-43) - Proposed repository outputs

Dependencies:
* Step 1.1 completion

### Step 1.3: Validate phase changes

Review the research note and file map for internal consistency before implementation dispatch. No code validation is required in this phase because no executable artifacts exist yet.

Validation commands:
* No command - Review against the revised council verdict and accepted constraints

## Implementation Phase 2: IaC and configuration artifacts

<!-- parallelizable: true -->

### Step 2.1: Scaffold the Bicep orchestration entrypoints

Owner: iac-author.

Create the `infra/bicep/` root with `main.bicep`, `types.bicep`, `README.md`, and an environment parameter file such as `environments/westeurope-internal.bicepparam`. The main orchestration should expose parameters for location, naming prefix, Entra ID settings, optional Key Vault private endpoint, diagnostic retention, tags, and the no-deploy-safe budget thresholds. The README should explain that the repository contains validation-only IaC artifacts and stops before any deployment action.

Files:
* infra/bicep/main.bicep - Resource orchestration entrypoint
* infra/bicep/types.bicep - Shared types and defaults
* infra/bicep/README.md - IaC usage and no-deploy boundary
* infra/bicep/environments/westeurope-internal.bicepparam - West Europe parameter set

Discrepancy references:
* DD-01

Success criteria:
* The entrypoint can compile without requiring subscription writes
* The parameter file encodes West Europe and cost-guardrail defaults

Context references:
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 21-35) - Selected Azure resource shape
* .github/instructions/bicep.instructions.md (Lines 17-94) - Structure, naming, parameter, and type conventions

Dependencies:
* Step 1.2 completion

### Step 2.2: Author the resource modules and outputs

Owner: iac-author with developer support for app settings conventions.

Create modules for networking, app service, sql, storage, key vault, monitoring, and governance. The modules should model only the approved architecture: public ingress on the web apps, private endpoints for SQL and Storage, managed identities, Key Vault secret references, diagnostic settings, budget alert definitions, tags, and resource locks. Keep deployment actions out of scope; author only the files and outputs required for later validation and human review.

Files:
* infra/bicep/modules/networking.bicep - VNet, subnets, NSGs, private DNS zones, private endpoints
* infra/bicep/modules/app-service.bicep - App Service plan, frontend app, backend app, managed identities, auth settings
* infra/bicep/modules/sql.bicep - Azure SQL server and Basic database with private connectivity
* infra/bicep/modules/storage.bicep - Storage account with private connectivity and minimum required services
* infra/bicep/modules/key-vault.bicep - Key Vault, RBAC, optional private endpoint toggle
* infra/bicep/modules/monitoring.bicep - Log Analytics, diagnostic settings, and metric alerts
* infra/bicep/modules/governance.bicep - Budget alerts, tags, and CanNotDelete locks

Success criteria:
* The module set covers every council condition that belongs in repo artifacts
* No module introduces containerization, NAT Gateway, WAF, Application Gateway, or deploy-time side effects outside template definitions

Context references:
* .copilot-tracking/squad/decisions.md (Lines 59-79) - Cost, security, and architecture conditions
* .github/instructions/bicep.instructions.md (Lines 95-188) - Module and type patterns

Dependencies:
* Step 2.1 completion

### Step 2.3: Author validation-friendly parameters and usage guidance

Owner: iac-author.

Add parameter and usage guidance that lets the future implementer validate the IaC locally or in CI without deploying. Include sample naming, required secret references, permitted optional toggles, and explicit notes that `az deployment`, `terraform apply`, and any portal provisioning are outside this pipeline stage.

Files:
* infra/bicep/environments/westeurope-internal.bicepparam - Finalized parameter values and toggles
* infra/bicep/README.md - Compile and review instructions only

Discrepancy references:
* DR-01

Success criteria:
* A reviewer can understand how to compile and inspect the IaC without touching Azure
* The no-deploy boundary is repeated in the IaC documentation

Context references:
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 49-53) - No-deploy implementation boundary

Dependencies:
* Step 2.2 completion

### Step 2.4: Validate phase changes

Run local and CI-safe Bicep validation only after the IaC files exist. Skip any command that would authenticate to Azure or create resources.

Validation commands:
* bicep build infra/bicep/main.bicep - Compile the main template
* bicep build-params infra/bicep/environments/westeurope-internal.bicepparam - Compile parameters

## Implementation Phase 3: Security, governance, and operations assets

<!-- parallelizable: true -->

### Step 3.1: Author the security and governance baseline

Owner: developer with security review.

Create human-readable baseline documents that translate the council conditions into implementation checks: Entra ID required, managed identities on both web apps, SQL and Storage private only, Key Vault access via managed identity, least-privilege RBAC, required tags, cost alerts, locks, diagnostics, and Azure Policy expectations. The baseline should also identify which controls are enforced in IaC versus which remain human approval checks.

Files:
* docs/security/azure-baseline.md - Security and governance control catalog
* docs/security/access-model.md - RBAC and approval-control notes

Discrepancy references:
* DD-01

Success criteria:
* Every accepted constraint and council condition maps to either an IaC control or a human gate
* The docs state that deployment, secret population, and RBAC assignment approval are out of scope for this stage

Context references:
* .copilot-tracking/squad/decisions.md (Lines 59-79) - Security and governance conditions
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 21-30) - Architecture and controls

Dependencies:
* Step 1.2 completion

### Step 3.2: Author operations and troubleshooting assets

Owner: developer with azure-diagnose review.

Create operations documents for post-deploy troubleshooting without actually deploying anything: startup checks, identity/auth failure triage, DNS/private endpoint checks for SQL and Storage, log locations, budget alert interpretation, and rollback expectations for future infrastructure changes. Keep the guidance specific to App Service, Azure SQL, Storage, Key Vault, and Log Analytics in West Europe.

Files:
* docs/operations/azure-webapp-runbook.md - Day-0 and day-2 operations guide
* docs/operations/troubleshooting.md - Symptom-based troubleshooting matrix

Success criteria:
* The runbook includes diagnostics sources for every planned Azure service
* The troubleshooting guide covers auth, DNS, private endpoint, and budget-alert scenarios

Context references:
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 45-47) - Operations deliverables
* .copilot-tracking/squad/decisions.md (Lines 53-79) - Diagnostics and post-launch follow-ups

Dependencies:
* Step 2.2 completion

### Step 3.3: Author a validation-only GitHub workflow

Owner: developer.

Create a workflow that checks out the repo with credentials disabled, compiles Bicep, and optionally runs markdown validation for the new docs. Do not add OIDC login, deployment jobs, or subscription-mutating commands. The workflow exists to keep the repo artifacts reviewable and safe under the no-deploy boundary.

Files:
* .github/workflows/validate-azure-artifacts.yml - Compile and lint only

Success criteria:
* The workflow declares explicit permissions and uses SHA-pinned actions
* The workflow contains no deployment or Azure login steps

Context references:
* .github/instructions/workflows.instructions.md (Lines 1-118) - Workflow security requirements

Dependencies:
* Steps 2.1 through 3.2 completion

### Step 3.4: Validate phase changes

Run repository-safe validation for the new workflow and documentation. Use lint or compile checks only.

Validation commands:
* bicep build infra/bicep/main.bicep - Reconfirm template validity after doc and workflow alignment
* Existing markdown or workflow lint command if the repo later adds one - Optional

## Implementation Phase 4: Review and final human gate

<!-- parallelizable: false -->

### Step 4.1: Review the repo artifacts against the council conditions

Owner: tester with security and cost-manager spot checks.

Review the produced repo artifacts for completeness, internal consistency, and constraint alignment. The review should verify cost-limiting choices, West Europe scoping, the App Service over containerization decision, data-plane privacy, managed identity usage, and the absence of deploy steps.

Files:
* .copilot-tracking/changes/2026-06-18/azure-web-app-repo-artifacts-changes.md - Future implementation change record
* docs/architecture/azure-internal-webapp.md - Reviewed architecture summary
* infra/bicep/ - Reviewed IaC tree

Success criteria:
* Review findings are limited to repo artifacts and do not require subscription changes
* Any remaining policy-sensitive item is explicitly called out for the final human gate

Context references:
* .copilot-tracking/squad/decisions.md (Lines 47-79) - Final review checklist source

Dependencies:
* Implementation Phases 2 and 3 completion

### Step 4.2: Prepare the final human gate package

Owner: lead with scribe handoff after implementation.

Prepare a concise gate package for the user that lists the repo artifacts created, the exact no-deploy boundary reached, the outstanding approval decisions for any subscription-affecting actions, and the recommended next command or role dispatch. The package should explicitly state that no Azure resources were provisioned, no cost was incurred, and no subscription state changed.

Files:
* .copilot-tracking/changes/2026-06-18/azure-web-app-repo-artifacts-changes.md - Change summary and pending approvals
* .copilot-tracking/plans/logs/2026-06-18/azure-web-app-repo-artifacts-log.md - Final discrepancy status

Success criteria:
* The user can approve or stop the next stage with full context
* The gate package lists every impactful action that remains out of scope

Context references:
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 49-53) - Stop-before-deploy boundary

Dependencies:
* Step 4.1 completion

### Step 4.3: Stop before any impactful Azure action

Owner: lead.

End the autopilot pipeline at the human gate. Do not run Azure login, subscription discovery, deployment, secret writes, RBAC assignments, or any command that changes cloud state. The next actor after approval is the implementer and Squad IaC Author, not the current planning artifact.

Success criteria:
* The pipeline ends with a human decision point instead of an Azure side effect
* The no-deploy boundary is preserved in every handoff artifact

Context references:
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 49-53) - Impactful-action boundary
* .copilot-tracking/squad/decisions.md (Lines 80-83) - Implementation gate permits planning, not deployment

Dependencies:
* Step 4.2 completion

## Dependencies

* Bicep CLI available for local compilation
* Existing repository markdown and workflow validation commands if added later

## Success Criteria

* The implementation handoff names all required repo artifacts, owners, and validations without any Azure-impacting action
* The selected artifact set keeps the default architecture within the revised council cost envelope and accepted privacy constraints