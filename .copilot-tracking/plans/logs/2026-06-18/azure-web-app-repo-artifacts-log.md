---
title: Azure Web App Repo Artifacts Planning Log
description: Discrepancies, implementation paths, and follow-on work for the no-deploy repo-artifact plan.
---
<!-- markdownlint-disable-file -->

# Planning Log: Azure Web App Repo Artifacts

## Discrepancy Log

Gaps and differences identified between research findings and the implementation plan.

### Unaddressed Research Items

* DR-01: The current repository has no established `infra/` or `docs/` delivery structure for this Azure workload, so the implementation plan must introduce a new artifact layout rather than extending existing Azure-specific paths.
  * Source: .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 37-43)
  * Reason: The workspace currently contains squad state and packaged skills, but no checked-in Azure solution structure for this app.
  * Impact: low
* DR-02: The original repo-only pass assumed Phase 2 IaC might remain deferred, but the approved artifact set now includes a checked-in `infra/bicep/` tree.
  * Source: user request on 2026-06-18
  * Reason: The repository now contains the compile-safe IaC artifact set, so the earlier deferment assumption is no longer current.
  * Impact: low

### Plan Deviations from Research

* DD-01: The plan treats the Key Vault private endpoint as optional by default instead of mandatory.
  * Research recommends: Model SQL and Storage as always private and carry forward the council tension on Key Vault privacy as a policy-sensitive item.
  * Plan implements: A `keyVaultPrivateEndpoint` toggle in IaC, defaulting to `false`, with the final human gate calling out the decision before any deployment.
  * Rationale: The accepted constraints explicitly require SQL and Storage to remain private, while the revised council verdict split on Key Vault default privacy. Making the control explicit in repo artifacts preserves compliance flexibility without forcing unnecessary monthly cost before a policy check.
* DD-02: The validation workflow was strengthened after the initial implementation pass.
  * Plan specifies: Add a validation-only workflow with no Azure login or deployment steps.
  * Implementation differs: The workflow now fails if Azure login, deployment, or subscription-mutating command patterns are introduced, instead of relying on reminder text alone.
  * Rationale: This makes the no-deploy boundary enforceable while keeping the workflow repo-only and safe.

## Implementation Paths Considered

### Selected: App Service with private data plane and optional Key Vault private endpoint

* Approach: Use two App Service B1 web apps with public Entra ID-protected ingress, one West Europe VNet, private endpoints for SQL and Storage, managed identity-backed Key Vault access, diagnostics, budget controls, and repo-only validation assets.
* Rationale: This is the lowest-complexity path that satisfies the accepted constraints, aligns with the revised council verdict, and leaves enough budget buffer under the $60 target.
* Evidence: .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 21-35)

### IP-01: Containerized web apps or fully private web ingress

* Approach: Replace App Service public ingress with containerized hosting or a fully private ingress pattern.
* Trade-offs: Improves ingress isolation, but adds network and compute complexity and risks exceeding the cost ceiling through premium networking, private ingress, or container platform overhead.
* Rejection rationale: The revised council verdict explicitly preferred App Service over containerization for this scale and budget.

### IP-02: Mandatory Key Vault private endpoint from the start

* Approach: Treat Key Vault exactly like SQL and Storage and require a private endpoint plus private DNS as part of the default path.
* Trade-offs: Tightens the secret plane, but adds cost and implementation complexity while the accepted constraints do not require private Key Vault by default.
* Rejection rationale: Keep the stronger control available, but do not make it the default until an explicit policy requirement is confirmed.

## Suggested Follow-On Work

* WI-01: Post-deployment security audit - Validate the deployed controls against Azure Security Benchmark v3 after the future deployment stage completes. (medium)
  * Source: .copilot-tracking/squad/decisions.md revised council follow-ups
  * Dependency: Human-approved deployment and environment availability
* WI-02: Week-2 cost and performance review - Compare actual resource cost and app behavior against the $60 target and App Service sizing assumptions. (medium)
  * Source: .copilot-tracking/squad/decisions.md revised council follow-ups
  * Dependency: At least one full billing cycle or representative usage period
* WI-03: Containerization ADR if requirements change - Capture the decision impact if later security or networking requirements force a move away from App Service. (low)
  * Source: .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md (Lines 27-30)
  * Dependency: New requirement showing App Service no longer fits
* WI-04: Add workflow linting such as `actionlint` if the repository later adopts a pinned local validation command. (low)
  * Source: implementation deviation DD-02
  * Dependency: Repository-approved workflow lint tooling
