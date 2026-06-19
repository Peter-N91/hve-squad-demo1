---
title: Azure Bicep Repo Artifacts
description: Repo-only Bicep artifacts for the approved West Europe internal Azure web app baseline.
---

## Purpose

This folder contains review-oriented Azure Bicep artifacts for the approved West Europe internal web app baseline. The scope is repo-only: compile, inspect, and review the files here without logging in to Azure or deploying resources.

## Included shape

* Two Azure App Service B1 web apps for frontend and backend
* One shared VNet with an integration subnet and a private-endpoints subnet
* Azure SQL Basic with a private endpoint
* Storage Account Standard GRS with a private endpoint for blob access
* Key Vault with managed identity access, disabled public network access, and an optional private endpoint toggle
* Log Analytics workspace and diagnostic settings
* Subscription budget definition, tags, and a resource-group `CanNotDelete` lock

## No-deploy boundary

> [!IMPORTANT]
> Do not run deployment commands from this repo-only package. Keep `az login`, `az deployment`, portal provisioning, secret writes, and RBAC approval changes out of scope until a reviewer explicitly approves a separate deployment stage.

Use these files only for static review and local compilation:

```bash
bicep build infra/bicep/main.bicep
bicep build-params infra/bicep/environments/westeurope-internal.bicepparam
```

## Reviewer checks

* Confirm the chosen `namePrefix` and `nameSuffix` values satisfy global uniqueness rules for App Service, SQL, Key Vault, and Storage.
* Confirm the Microsoft Entra tenant ID and client IDs map to approved app registrations.
* Confirm the SQL administrator secret is supplied only through an approved deployment-time secret store.
* Confirm whether the approved environment requires `keyVaultPrivateEndpoint = true` for private path enforcement in addition to the baseline public network disablement. The default here remains `false` to stay within the approved cost guardrails.
* Confirm whether subscription budget contacts should use explicit emails in addition to the built-in `Owner` role notification.

## Structure

* [main.bicep](./main.bicep) orchestrates the baseline modules and exposes review-friendly outputs.
* [types.bicep](./types.bicep) records shared types and defaults for reviewer alignment.
* [environments/westeurope-internal.bicepparam](./environments/westeurope-internal.bicepparam) captures the approved West Europe parameter set.
* [modules/](./modules/) contains the resource modules for networking, app service, SQL, storage, Key Vault, monitoring, and governance.