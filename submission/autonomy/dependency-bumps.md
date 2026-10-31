# Autonomy Policy: Dependency Bumps

**Workflow:** Automated dependency version bumps  
**Author:** [your name]  
**Date:** 2026-10-31  
**Day-one level:** Level 0 — Suggest only  

## Why Level 0 on day one

Two of six engineers are new to this codebase. They cannot yet judge  
whether a bumped package changes behaviour in the approval path or  
the planned PayEx payment flow. A human must see every change before  
it merges. We step up only after evidence is collected.

## Levels table

| Level | Name | What the agent does | Human gate |
|-------|------|---------------------|------------|
| 0 | Suggest only | Opens a GitHub issue listing available updates with changelog links | Engineer reads and decides whether to act. No code changes. |
| 1 | PR, human merges | Opens a PR with the version bump and lockfile diff | A codeowner reviews and merges manually. CI must be green. |
| 2 | Auto-merge patch | Merges patch-only bumps automatically | CI green AND diff must be lockfile-only AND smoke test must cover the approval path |

## Controls at each level

**Level 0**  
- No code is changed by the agent.  
- Risk is very low but not zero — a suggestion could misstate a version  
  or miss a security advisory. Engineer must verify before acting.

**Level 1**  
- CODEOWNERS file must exist and gate the merge  
- Reviewer must be domain-qualified for the changed package area —  
  payment or auth packages require the named payment/identity owner  
  plus an independent security reviewer (not the same person)  
- CI must pass: unit tests, integration tests, and approval-path smoke test  
- Transitive dependency diff must be included in the PR (lockfile before/after)  
- Full dependency tree scanned for advisories — not just direct dependencies  
- A rollback plan must be documented in the PR before merge  
- Major and minor bumps stay at Level 1 indefinitely — never auto-merged

**Level 2**  
- Applies to allowlisted packages only (see allowlist below)  
- Diff must be lockfile-only (enforced by a PR check script)  
- Payment, auth, and audit-path packages are permanently excluded  
- Smoke test must exercise the full Submit → Approve → [PayEx outbox write] path  
- Any failure auto-raises a GitHub issue and pauses auto-merge for that package  

### Level 2 allowlist — only these are eligible for auto-merge
- Test utilities: xUnit, Moq, FluentAssertions  
- Build tooling: dotnet-format, Coverlet  

Never auto-merged regardless of category:  
- Microsoft.AspNetCore.*  
- Any package in the PayEx HTTP client or outbox path  
- Any package with a security advisory in the last 90 days

## Evidence needed to move up one level

**Level 0 → Level 1:**  
- 4 consecutive weeks of suggest-only with no missed breakage  
- All 6 engineers have manually reviewed at least one bump suggestion  
- Smoke test covering the approval path exists and is green  

**Level 1 → Level 2:**  
- At least 20 eligible patch PRs across at least 90 calendar days  
- Must cover the package categories proposed for the allowlist  
- Every PR must have on record: CI result, transitive dep scan, deployment outcome,  
  incident linkage (or "no incident")  
- Zero production regressions, rollbacks, or unresolved security findings  
  during the observation period  
- All engineers have reviewed at least one bump PR each  

### Per-PR evidence record (required for every Level 1 bump)

| PR | Package | Version | Transitive diff clean | CI | Deployed | Incident |
|----|---------|---------|----------------------|----|----------|----------|
| #  | name    | x → y   | yes / no + notes     | ✓  | yes/no   | none / #link |

## Who approves a level promotion

Two independent approvals required — the proposer cannot be one of the two:  

1. Engineering lead or designated dependency-policy owner  
2. Security reviewer independent of the proposer  

Both approvers commit to this file recording:  
- Effective date  
- Exact allowlisted package scope approved  
- Rollback procedure (how to disable auto-merge immediately)  
- Next scheduled review date  

No automated promotion is permitted under any circumstance. 

## What would make us step back down

- Any bump causes a production incident  
- A security advisory is found in a recently auto-merged package  
- A new engineer joins who has not yet reviewed the bump history  
- The PayEx integration goes live (adds new risk surface — revisit at Level 1)

## What was added after gap review (2026-10-31)

Copilot gap analysis identified five gaps in the original draft.  
The following were accepted and added above:  
- Domain-qualified reviewer requirement at Level 1  
- Transitive dep diff and full tree scan at Level 1  
- Rollback plan required in PR before merge  
- 90-day minimum window for Level 1 → Level 2 evidence  
- Two independent approvers for promotion, proposer excluded  

The following were reviewed and rejected as disproportionate  
for a 6-person team at this stage:  
- Package provenance and build script review (no tooling exists yet)  
- Manual license review for every bump (no legal process established)  
- Full manual transitive review beyond automated scan