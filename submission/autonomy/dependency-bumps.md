# Autonomy Policy: Dependency Bumps

**Workflow:** Automated dependency version bumps  
**Author:** Harshit Bhargava
**Date:** 2026-10-31  
**Day-one level:** Level 0 — Suggest only

## Day-one decision

Two of six engineers are new to this codebase and cannot yet assess every
dependency's effect on invoice approval or the planned PayEx path. Start at
Level 0: the agent may report updates and changelog links, but may not edit
files or open/merge a PR. An engineer verifies every suggestion.

## Autonomy levels and controls

| Level | Agent may | Required control / human gate |
|---|---|---|
| 0 — Suggest | List updates with source and changelog | Engineer verifies package, version, advisory status, and decides whether to proceed; no code changes. |
| 1 — PR, human merges | Open a version/lockfile PR | CODEOWNERS review; green unit, integration, and approval-path smoke tests; full transitive diff and advisory scan; rollback plan. Payment/auth changes also need the domain owner and an independent security reviewer. Major/minor updates remain at this level. |
| 2 — Auto-merge patch | Merge eligible patch-only PRs | Allowlist only; lockfile-only check; green CI and approval smoke test; automated pause/issue on failure; immediate rollback switch and human monitoring. Never includes ASP.NET Core, payment/auth/audit paths, or packages with a recent security advisory. |

Level 2 allowlist, if approved: xUnit, Moq, FluentAssertions, dotnet-format,
and Coverlet. The PayEx/outbox workflow is planned, not current application
behavior, and remains excluded from auto-merge.

## Evidence and promotion authority

- **Level 0 → 1:** Four consecutive weeks of suggestions with no missed
  breakage; all six engineers review at least one suggestion; approval-path
  smoke test exists and passes.
- **Level 1 → 2:** At least 20 eligible patch PRs over 90 days across the
  proposed package categories. Record CI, transitive scan, deployment
  outcome, and incident/no-incident for every PR; require zero regressions,
  rollbacks, or unresolved security findings; every engineer reviews at
  least one PR.
- The engineering lead/dependency-policy owner and an independent security
  reviewer approve promotions; neither may be the proposer. Record effective
  date, exact scope, rollback procedure, and next review. Promotion is never
  automatic.

## Step-down triggers

Return to the previous level after any production regression, rollback,
recent advisory in an auto-merged package, or loss of required CI/monitoring.
Revisit at Level 1 before the PayEx integration goes live. Review the
allowlist whenever a new engineer joins or a control changes.
