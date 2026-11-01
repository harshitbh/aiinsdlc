# Lethal Trifecta Audit

**Agent setup audited:** GitHub Copilot (auto model) configured via
.github/copilot-instructions.md, running in Ask and Agent modes with
read/write access to the full repository and terminal execution.
**Date:** 2026-10-31

## Assessment

| Leg | Present | Evidence | Worst-case failure |
|-----|---------|----------|-------------------|
| Leg 1 — Private data access | YES | Copilot reads the full repo including invoice domain models, approval logic, session handling, and ops/ incident logs and pipeline data | Agent leaks 7-year financial approval history |
| Leg 2 — Untrusted input | YES | Invoice descriptions submitted by external vendors are processed by the agent in any production triage or summarisation workflow | Vendor embeds prompt injection in description — agent follows the instruction |
| Leg 3 — External action | YES | Copilot in Agent mode writes files, runs terminal commands, pushes commits, and opens PRs | Injected instruction causes agent to push malicious code or approve fraudulent invoice without engineer noticing |

## All three legs present: YES

The agent has access to repository contents, can consume potentially untrusted content from invoices and incident material, and can execute actions through Agent mode. This satisfies all three conditions of the Lethal Trifecta.

## Decision: Remove Leg 3

Restrict the agent to read-and-suggest mode only.

### What changes

- Agent MAY read code, logs, ADRs, incidents, and operational documentation
- Agent MAY generate summaries, reviews, design suggestions, and drafts
- Agent MAY NOT execute terminal commands without explicit engineer approval
- Agent MAY NOT edit files automatically
- Agent MAY NOT create commits or pull requests automatically
- Agent mode disabled for production-support workflows
- Ask mode only

### Why Leg 3

Removing Leg 1 would prevent architecture analysis, review assistance, and incident investigation.

Removing Leg 2 is not practical because operational workflows inherently process externally supplied information.

Removing Leg 3 preserves the benefits of repository analysis while preventing autonomous actions based on potentially manipulated input.

## Revisit triggers

- 90 days of read-only agent mode with zero prompt-injection incidents
- SOC 2 audit passes with no AI agent findings
- All six engineers complete AI security awareness training
- Formal security review of Copilot data boundary completed and approved

## Most likely failure scenario with all three legs

Vendor submits invoice with crafted description at month-end peak.
Agent in Agent mode reads it and follows embedded instruction.
Opens PR approving fraudulent invoices.
Engineer on call under month-end pressure merges without reading diff.
Payment goes through PayEx. Reversal takes days and may be partial.
Read-only mode breaks this chain at the external-action step.