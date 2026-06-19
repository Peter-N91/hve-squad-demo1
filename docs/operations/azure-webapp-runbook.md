---
title: Azure Web App Runbook
description: Day-0 and day-2 operational guidance for the repo-only Azure web app baseline.
sidebar_position: 1
ms.date: 2026-06-18
ms.topic: how-to
keywords:
  - runbook
  - app service
  - log analytics
  - budget alerts
---

## Scope and boundary

This runbook prepares operators for the approved Azure shape without performing a deployment. Use it as a post-deploy reference once a separate human-approved implementation stage exists.

> [!WARNING]
> This repository stage does not authorize deployment, Azure sign-in, secret population, or RBAC changes.

## Expected service set

The eventual operational footprint is expected to include:

* Frontend App Service in West Europe
* Backend App Service in West Europe
* Azure SQL Database with private connectivity
* Azure Storage with private connectivity
* Azure Key Vault with managed identity access
* Log Analytics workspace with platform diagnostics
* Budget alerts and resource locks

## Day-0 review before deployment

Confirm these items in the repo package before approving live work:

* The region is West Europe only.
* Public ingress is limited to Entra ID-protected web apps.
* SQL and Storage are modeled as private-only dependencies.
* The Key Vault private endpoint posture is called out as a policy decision.
* The validation workflow contains no Azure login or deployment steps.

## Day-2 operational focus

After a future deployment, operators should monitor these signals first:

| Service | Primary signals |
| --- | --- |
| App Service | Startup failures, auth failures, 5xx rates, configuration drift |
| Azure SQL | Connectivity failures, auth failures, firewall or private DNS drift |
| Storage | Blob access failures, DNS resolution, managed identity authorization |
| Key Vault | Secret reference failures, permission denials, network access errors |
| Platform | Budget alerts, lock failures, policy non-compliance, diagnostic gaps |

## Budget operations

The approved cost posture relies on active monitoring:

* Investigate the 80% budget alert before service changes are approved.
* Treat the 100% alert as a change-control event.
* Do not upscale SKUs without written approval.

## Change safety rules

When the deployment stage eventually starts, require human approval before:

* Enabling premium SKUs
* Adding NAT Gateway, WAF, or Application Gateway
* Switching to container hosting
* Expanding to another region
* Making Key Vault network controls less restrictive

## Handoff note

This runbook is implementation-ready, but inactive until a separate deployment approval occurs.
