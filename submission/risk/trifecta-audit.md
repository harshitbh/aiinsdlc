# Lethal Trifecta Audit

**Audit date:** 2026-10-31
**Scope:** Copilot use for this assignment, not a production agent integrated
with the invoice application.

## Scope and evidence

The requested agent setup is not described at the end of `ops/README.md`.
That file describes incident, pipeline, and evaluation materials, and says
the production deployment assumptions are not implemented
(`ops/README.md:6-23`). The repository's `.github/copilot-instructions.md`
sets codebase rules and citation/logging requirements, but does not configure
tool permissions, read-only mode, or external-action restrictions
(`.github/copilot-instructions.md:3-18`). I therefore assess the actual
assignment workflow and mark scenario-only claims as inferred rather than
pretending ops specifies an agent.

## Assessment

| Leg | Assessment | Evidence and boundary |
|---|---|---|
| 1 — Private data access | **Conditional / not demonstrated with real private records.** The assistant can read workspace files. The ops pack explicitly says its names, hosts, and figures are invented and contains no real customer or vendor (`ops/README.md:22-23`). Access to real private production data is not established by this repository. |
| 2 — Untrusted input | **Conditional.** The assistant can be given diffs, logs, or pasted text that should be treated as untrusted. The invoice application has no agent integration; the claim that a vendor invoice is automatically processed by Copilot is **INFERRED**, not current behavior. |
| 3 — External action | **Present for local workspace changes; broader actions unverified.** This assignment workflow has tools that can edit files and run commands. The instruction file does not disable those capabilities. Automatic commits, pull requests, deployments, or PayEx actions are not evidenced here and must not be claimed as current behavior. |

**Decision:** For production-support workflows, remove Leg 3: allow read-and-
suggest only, with no repository writes, shell execution, commits, pull
requests, or deployment/payment tools. A written instruction such as “Ask
mode only” is not a technical permission boundary. This decision is a
proposed control until the Copilot/organization settings actually deny those
capabilities and an administrator verifies the denial.

Until that enforcement is verified, do not provide real customer, payment,
or production incident data to an agent with write/command access. Require a
human to transfer reviewed summaries into the workflow instead.

## Revisit triggers

- The organization enables and tests a permission boundary that prevents
  write/command/external actions for production-support sessions.
- A documented data-boundary review confirms which private repositories and
  sources the agent can access.
- A controlled prompt-injection exercise and security review pass, with
  owners assigned for monitoring and incident response.
- A production workflow is proposed that needs any external action; review
  and approve that specific action scope before enabling it.

Do not treat “90 days with no reported incident” by itself as evidence that
the control works; absence of reports does not establish a denied capability.
