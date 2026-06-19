---
title: Azure Security Baseline
description: Security and governance baseline for the repo-only Azure web app implementation package.
sidebar_position: 1
ms.date: 2026-06-18
ms.topic: reference
keywords:
  - azure security
  - governance
  - entra id
  - managed identity
---

## Scope

This baseline translates the approved council conditions into implementation checks for repository artifacts. It does not approve deployment activity.

> [!IMPORTANT]
> Deployment, secret population, policy assignment, RBAC grants, and any subscription mutation require a separate human approval step.

## Control catalog

| Control area | Requirement | Implemented by |
| --- | --- | --- |
| Region | West Europe only | IaC and documentation |
| User authentication | Entra ID required for all users | IaC and documentation |
| App identity | Managed identity on frontend and backend | IaC and documentation |
| SQL access | Private endpoint, public access disabled | IaC and documentation |
| Storage access | Private endpoint, public access disabled | IaC and documentation |
| Key Vault access | Managed identity required | IaC and documentation |
| Key Vault network posture | Private endpoint only if policy mandates it | Final human approval and optional IaC toggle |
| Network filtering | NSGs on the private-endpoints subnet | IaC |
| DNS privacy | Private DNS zones for SQL, Storage, and Key Vault | IaC and documentation |
| Logging | Diagnostics to Log Analytics | IaC and documentation |
| Alerting | Failed auth, data access, and budget alerts | IaC and documentation |
| Governance | Tags, locks, policy-driven controls | IaC and documentation |
| Elevated access | Approval required for Key Vault and database elevation | Final human approval |

## Minimum governance posture

The baseline expects these governance controls to be present in the eventual deployment artifacts:

* Required tags for owner, environment, application, and cost center
* CanNotDelete locks on production-scoped resources or the resource group
* Azure Policy coverage for encryption, managed identity usage, and restricted public endpoints
* Budget alerts at 80% and 100% of the $60 monthly ceiling

## Cost-sensitive boundaries

The council conditions are cost-constrained. The baseline therefore assumes:

* B1 App Service for both apps
* Basic SQL
* Standard GRS Storage
* No NAT Gateway
* No WAF
* No Application Gateway
* No premium SKU substitutions without written approval

## Human approval items

These items remain outside repo-only implementation and must be approved explicitly before live execution:

* Final decision on a Key Vault private endpoint if policy requires it
* Secret values and Key Vault population
* RBAC assignment for operators, break-glass access, and elevated database access
* Policy exemptions, if any are requested
* Any SKU change that raises the cost profile

## Reviewer use

A reviewer should reject the package if any artifact:

* Suggests Azure login as part of validation
* Treats SQL or Storage as public services
* Removes Entra ID from the web ingress path
* Normalizes premium network controls that exceed the approved budget posture
