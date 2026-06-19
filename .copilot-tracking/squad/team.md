---
description: "Squad roster: roles and the deployed HVE Core agents that fill them"
---

# Squad Roster

## Members

| Role             | Member Name | Agent Name (Primary)         | Alternate Agents                                       | Invocation         | Model Tier |
|------------------|-------------|------------------------------|--------------------------------------------------------|--------------------|------------|
| researcher       | Beta        | Task Researcher              | Researcher Subagent, Codebase Profiler, Meeting Analyst | runSubagent / task | fast       |
| lead             | Alpha       | Task Planner                 | RPI Agent, Phase Implementor, Task Challenger          | runSubagent / task | default    |
| developer        | Gamma       | Task Implementor             | Phase Implementor                                      | runSubagent / task | default    |
| tester           | Delta       | Task Reviewer                | Code Review Full, Code Review Standards, Code Review Functional, PR Review, Implementation Validator, Plan Validator, RPI Validator | runSubagent / task | fast       |
| architect        | Epsilon     | System Architecture Reviewer | Arch Diagram Builder, ADR Creator, Network ISA-95 Planner | runSubagent / task | default    |
| azure-architect  | Zeta        | Squad Azure Architect        | —                                                      | runSubagent / task | default    |
| security         | Eta         | Security Planner             | Security Reviewer, SSSC Planner, Skill Assessor, Finding Deep Verifier, Report Generator, Dependency Reviewer, Codebase Profiler | runSubagent / task | default    |
| iac-author       | Theta       | Squad IaC Author             | —                                                      | runSubagent / task | default    |
| deployer         | Iota        | Squad Deployer               | —                                                      | runSubagent / task | default    |
| asbuilt-author   | Kappa       | Squad As-Built Author        | —                                                      | runSubagent / task | default    |
| azure-diagnose   | Mu          | Squad Azure Diagnose         | —                                                      | runSubagent / task | default    |
| cost-manager     | Lambda      | Squad Cost Manager           | —                                                      | runSubagent / task | default    |
| scribe           |             | Squad Scribe                 | Memory                                                 | runSubagent / task | fast       |
