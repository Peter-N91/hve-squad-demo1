---
title: Azure Troubleshooting Guide
description: Symptom-based troubleshooting guide for the approved Azure web app baseline.
sidebar_position: 2
ms.date: 2026-06-18
ms.topic: troubleshooting
keywords:
  - troubleshooting
  - entra id
  - private endpoint
  - sql
  - storage
---

## Scope

This guide documents likely failure modes for the approved architecture. It is written for review and future operations, not for live execution in the current repo-only stage.

## Symptom matrix

| Symptom | Likely area | First checks |
| --- | --- | --- |
| Users cannot sign in | Entra ID or App Service auth | Confirm auth settings, redirect URI alignment, and failed sign-in logs |
| Frontend reaches backend but backend cannot load secrets | Managed identity or Key Vault | Check identity assignment, Key Vault access policy or RBAC path, and secret reference logs |
| Backend cannot reach SQL | Private DNS, private endpoint, or SQL auth | Check DNS resolution for SQL, private endpoint health, and connection failures |
| Backend cannot reach Storage | Private DNS, private endpoint, or RBAC | Check DNS resolution for Storage, private endpoint health, and data-plane authorization |
| Unexpected budget alert | Cost drift | Check SKU changes, extra endpoints, and diagnostic ingestion volume |
| Missing diagnostics | Diagnostic settings or workspace linkage | Confirm each resource sends logs and metrics to Log Analytics |

## Authentication failures

If the sign-in path fails after a future deployment:

* Check whether App Service authentication is enabled for both apps.
* Confirm that only Entra ID-backed access is allowed.
* Review failed sign-in telemetry before making any configuration change.

## Private connectivity failures

If SQL or Storage connectivity fails:

* Verify the expected private endpoint exists for the service.
* Verify the matching private DNS zone is linked correctly.
* Check whether any later change reintroduced public endpoint assumptions.

## Key Vault access failures

If Key Vault secret references fail:

* Confirm the workload identity exists and is assigned correctly.
* Confirm the approval path for Key Vault access was completed during deployment.
* If policy required a private endpoint, verify that the implementation matched the approved toggle.

## Budget and governance failures

If cost or compliance alerts fire:

* Treat unexpected premium SKUs as a governance defect.
* Review resource tags, locks, and policy assignments.
* Escalate any request to relax private-data controls or identity requirements.

## No-deploy reminder

This document does not authorize remediation actions in Azure. It defines what operators should inspect after a separately approved deployment exists.
