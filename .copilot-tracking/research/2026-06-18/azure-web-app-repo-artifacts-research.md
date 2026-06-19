---
title: Azure Web App Repo Artifacts Research
description: Verified planning context for the no-deploy autopilot artifact set after the revised council verdict.
---
<!-- markdownlint-disable-file -->

# Research: Azure Web App Repo Artifacts

## Verified constraints

* Region is West Europe only.
* The solution is an internal team application.
* Frontend and backend may use public ingress when Entra ID protected.
* Azure SQL and Storage must remain private.
* Secrets must flow through Key Vault and managed identity.
* VNet and subnets are required.
* Monthly cost target stays under $60.
* The user must approve anything that spends money or changes the subscription.
* The current pipeline must stop before any deployment or subscription-changing action.

## Selected architecture baseline

The revised council verdict supports Azure App Service over containerization for this scope. The implementation target is two Azure App Service B1 web apps, one for the frontend and one for the backend, both in West Europe and both protected by Entra ID authentication. A single VNet should provide an integration subnet for App Service regional VNet integration and a dedicated subnet for private endpoints.

Azure SQL Database should use the Basic tier and private connectivity only. Storage should use Standard GRS and private connectivity only. Key Vault should be accessed through managed identity and secret references. Log Analytics should receive diagnostics from App Service, SQL, Storage, Key Vault, and networking resources. Resource locks, tags, and budget alerts belong in the repo artifacts because they are part of the approved governance shape.

Containerization is not justified unless a later requirement forces fully private web ingress or another feature App Service cannot meet. The planning path should therefore optimize for App Service first and treat containers as an alternate path, not the default.

A Key Vault private endpoint is the only notable conditional item. The accepted constraints require private SQL and Storage, but the revised council findings split on whether Key Vault must also be private by default. The safest implementation plan is to model Key Vault private endpoint support as an optional IaC toggle with a default of `false`, then surface the policy decision at the final human gate before any deployment.

## Cost guardrails

The revised council estimate placed the default shape at roughly $38 to $50 per month: two B1 App Service instances, Basic SQL, Standard GRS Storage, Key Vault Standard, SQL and Storage private endpoints, and light Log Analytics usage. This leaves a buffer below the $60 ceiling for modest monitoring costs but not for premium networking or compute services.

The repo artifact plan must therefore exclude NAT Gateway, Application Gateway, WAF, premium App Service SKUs, and container orchestration by default. It should also include budget-alert and tagging artifacts so the future deploy step is constrained before anyone provisions resources.

## Repository outputs to plan for

The repo needs a dedicated IaC tree under infra/bicep/ with a main orchestration file, shared types, environment parameters, and modules for networking, app service, sql, storage, key vault, monitoring, and governance. The repo also needs human-readable artifacts: architecture summary, App Service decision note or ADR, security baseline, access model notes, operations runbook, troubleshooting guide, and a validation-only GitHub Actions workflow.

The workflow must compile or lint artifacts only. It must not log in to Azure, deploy resources, discover subscriptions, or request OIDC setup in this pipeline stage.

The repo artifacts should also encode the no-deploy boundary explicitly so the implementer and Squad IaC Author can continue from a safe stopping point.

## Operational and review implications

Troubleshooting assets should focus on Entra ID auth failures, App Service configuration drift, private DNS and private endpoint issues for SQL and Storage, Key Vault reference failures, diagnostics locations, and cost-alert interpretation. Review criteria should confirm West Europe scoping, data-plane privacy, managed identity usage, and the absence of deployment steps.

## No-deploy boundary

This planning track ends at repo artifacts and human review. It does not include Azure login, deployment commands, secret population, role assignment changes, resource creation, subscription discovery, or any other cloud-side mutation.

The final gate must present the generated repo artifacts, any unresolved policy toggle such as optional Key Vault private endpoint use, and the exact impactful actions that remain blocked pending user approval.