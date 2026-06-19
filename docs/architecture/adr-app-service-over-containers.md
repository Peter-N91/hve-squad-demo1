---
title: ADR App Service Over Containers
description: Decision record for choosing Azure App Service over container hosting for the internal web app baseline.
sidebar_position: 2
ms.date: 2026-06-18
ms.topic: concept
keywords:
  - adr
  - azure app service
  - containers
  - cost
---

## Status

Accepted for the repo-only baseline.

## Decision

Use Azure App Service B1 for the frontend and backend as the default compute model. Do not standardize on container hosting for the initial implementation path.

## Context

The revised council verdict is Go-With-Conditions for a small internal Azure web workload with these constraints:

* West Europe only
* Public ingress protected by Entra ID
* Private SQL and Storage
* Managed identity for secret access
* Governance and diagnostics enabled
* Monthly cost target below $60

## Rationale

App Service is the lower-risk fit for this workload because it:

* Keeps the baseline under the current cost envelope more reliably
* Avoids container platform overhead that the approved design does not need
* Supports the required identity, VNet integration, and diagnostic controls
* Reduces the amount of operational documentation needed for the first deployment stage

Containerization stays available as a later change path if requirements shift. It is not justified by the current cost, security, or scale assumptions.

## Consequences

Positive consequences:

* Simpler repo handoff for infrastructure authors and reviewers
* Lower probability of cost drift before the first deployment
* Clearer separation between public web ingress and private data services

Negative consequences:

* The workload does not start from a container-first portability model
* A future move to container hosting would require a fresh architecture review and updated runbooks

## Follow-up trigger

Revisit this decision only if one of these conditions becomes true:

* The application requires container-specific runtime control
* Security policy later requires a different ingress or hosting posture
* Performance or scaling needs exceed the B1 App Service baseline

## No-deploy boundary

This ADR approves a repo baseline only. It does not authorize Azure login, deployment, image publishing, secret writes, or live configuration changes.
