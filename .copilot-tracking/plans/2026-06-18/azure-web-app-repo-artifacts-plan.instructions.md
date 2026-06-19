---
applyTo: '.copilot-tracking/changes/2026-06-18/azure-web-app-repo-artifacts-changes.md'
description: Implementation plan for repo-only Azure architecture artifacts after the revised autopilot council verdict.
---
<!-- markdownlint-disable-file -->

# Implementation Plan: Azure Web App Repo Artifacts

## Overview

Produce a concise, implementation-ready repo-only handoff for the approved West Europe Azure web app shape, covering IaC, architecture, security, operations, validation, and the final no-deploy human gate.

## Objectives

### User Requirements

* Create the next autopilot pipeline artifact after the revised council Go-With-Conditions verdict. - Source: user request on 2026-06-18
* Keep the scope practical, implementation-ready, and limited to repo artifacts only. - Source: user request on 2026-06-18
* Cover Azure architecture choices, IaC deliverables, security and governance controls, operational and troubleshooting assets, and validation steps. - Source: user request on 2026-06-18
* Stop before any impactful Azure action, deployment, or subscription change. - Source: user request on 2026-06-18

### Derived Objectives

* Freeze App Service as the default compute model and treat containerization as an alternate path because the revised council verdict found App Service to be the lowest-cost fit. - Derived from: .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md
* Carry forward the Key Vault private-endpoint decision as an explicit optional toggle so the implementer can stay within cost guardrails while preserving a stricter policy path. - Derived from: accepted constraints plus DD-01 in the planning log
* Assign each future repo artifact to a squad role so the implementer and Squad IaC Author can pick up the next stage without re-planning. - Derived from: squad roster and autopilot handoff needs

## Context Summary

### Project Files

* .copilot-tracking/squad/decisions.md - Revised council verdict and conditions for the approved Azure shape
* .copilot-tracking/squad/team.md - Role ownership for the follow-on implementation stage
* .github/instructions/bicep.instructions.md - Bicep structure, naming, and module conventions for planned IaC files
* .github/instructions/workflows.instructions.md - Validation workflow security requirements
* .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md - Lightweight research grounding this plan

### References

* .copilot-tracking/plans/logs/2026-06-18/azure-web-app-repo-artifacts-log.md - Discrepancies, implementation-path selection, and follow-on work

### Standards References

* .github/instructions/markdown.instructions.md - Markdown file requirements for tracked planning artifacts
* .github/instructions/writing-style.instructions.md - Writing and tone guidance for repo documentation artifacts

## Implementation Checklist

### [x] Implementation Phase 1: Research refinements and artifact freeze

<!-- parallelizable: false -->

* [x] Step 1.1: Confirm the architecture note and the single open policy toggle
  * Owner: researcher with azure-architect review
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 17-39)
* [x] Step 1.2: Freeze the repo artifact map and ownership before writing implementation files
  * Owner: lead, handed to developer and iac-author
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 41-62)
* [x] Step 1.3: Validate the phase-1 scope against the revised verdict and accepted constraints
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 64-70)

### [x] Implementation Phase 2: IaC and configuration artifacts

<!-- parallelizable: true -->

* [x] Step 2.1: Create the `infra/bicep/` entrypoints for the approved West Europe shape
  * Owner: iac-author
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 75-99)
* [x] Step 2.2: Author modules for networking, app service, sql, storage, key vault, monitoring, and governance
  * Owner: iac-author with developer support
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 101-125)
* [x] Step 2.3: Add non-deploy usage guidance and environment parameters for local or CI validation only
  * Owner: iac-author
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 127-148)
* [x] Step 2.4: Validate the IaC with compile-only commands
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 150-156)

### [x] Implementation Phase 3: Security, governance, and operations assets

<!-- parallelizable: true -->

* [x] Step 3.1: Create the security and governance baseline documents
  * Owner: developer with security review
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 162-184)
* [x] Step 3.2: Create the App Service, data-plane, and diagnostics runbook assets
  * Owner: developer with azure-diagnose review
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 186-205)
* [x] Step 3.3: Add a validation-only GitHub workflow with no Azure login or deployment steps
  * Owner: developer
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 207-224)
* [x] Step 3.4: Re-run repository-safe compile or lint checks
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 226-232)

### [x] Implementation Phase 4: Review and final human gate

<!-- parallelizable: false -->

* [x] Step 4.1: Review the repo artifacts against cost, security, and architecture conditions
  * Owner: tester with security and cost-manager spot checks
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 238-257)
* [x] Step 4.2: Prepare the final human gate package and handoff summary
  * Owner: lead with scribe handoff after implementation
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 259-277)
* [x] Step 4.3: Stop at the no-deploy boundary before any Azure-impacting action
  * Owner: lead
  * Details: .copilot-tracking/details/2026-06-18/azure-web-app-repo-artifacts-details.md (Lines 279-294)

## Planning Log

See .copilot-tracking/plans/logs/2026-06-18/azure-web-app-repo-artifacts-log.md for discrepancy tracking, implementation paths considered, and suggested follow-on work.

## Dependencies

* Revised council Go-With-Conditions verdict recorded in .copilot-tracking/squad/decisions.md
* Bicep CLI for compile-only validation in the future implementation stage
* No Azure login, deployment credential, or subscription write permission in this planning stage

## Success Criteria

* The next implementer receives an ordered repo-artifact plan with explicit file ownership and validation steps. - Traces to: user request on 2026-06-18
* The planned artifact set preserves West Europe scope, App Service preference, private SQL and Storage, Key Vault plus managed identity usage, and the sub-$60 cost posture. - Traces to: .copilot-tracking/research/2026-06-18/azure-web-app-repo-artifacts-research.md
* The autopilot pipeline stops at a final human gate before any provisioning, subscription mutation, or cost-incurring action. - Traces to: user request on 2026-06-18
