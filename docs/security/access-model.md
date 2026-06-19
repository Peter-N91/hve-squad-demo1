---
title: Azure Access Model
description: Access and approval model for the repo-only Azure web app baseline.
sidebar_position: 2
ms.date: 2026-06-18
ms.topic: reference
keywords:
  - rbac
  - managed identity
  - approvals
  - key vault
---

## Identity model

The baseline uses Microsoft Entra ID for user authentication and managed identities for workload-to-resource access.

| Actor | Access model | Notes |
| --- | --- | --- |
| Internal user | Entra ID sign-in to frontend and backend | Mandatory for all interactive access |
| Frontend App Service | Managed identity | Use only the permissions required for downstream calls |
| Backend App Service | Managed identity | Use for Key Vault, SQL auth path if adopted, and storage access |
| Operations reviewer | Human RBAC assignment | Approved outside this repo-only stage |
| Break-glass admin | Human RBAC assignment | Exceptional path only, approved outside this stage |

## Approval boundaries

The repo artifacts can describe the target access model, but they must not execute these actions:

* Grant Azure RBAC roles
* Assign Key Vault data-plane permissions
* Create break-glass identities
* Approve elevated database access
* Populate secrets or connection material

Those actions require final human approval because they affect live access and subscription state.

## Least-privilege guidance

Reviewers should expect the future IaC to follow these rules:

* Scope app identities to only the resources they need
* Keep data-plane access separated from management-plane roles
* Prefer resource-scoped permissions over broad subscription assignments
* Audit any exception that expands Key Vault or SQL access

## Condition map

| Council condition | Repo handling |
| --- | --- |
| Mandatory Entra ID for users | Documentation now, IaC later |
| Managed identities on both apps | Documentation now, IaC later |
| Approval controls for Key Vault and elevated database permissions | Final human approval |
| RBAC audits | Documentation now, operational review later |

## Reviewer-sensitive assumptions

This access model assumes:

* The internal user population already exists in Entra ID.
* The identity team will review app registration and enterprise app settings during the live deployment stage.
* The security team will decide whether Key Vault network isolation must move from managed-identity-only access to a private endpoint requirement.
