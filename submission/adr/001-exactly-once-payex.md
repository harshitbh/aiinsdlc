# ADR-001: Exactly-once PayEx submission
Status: Draft — 2026-10-31

## My position before Copilot
Transactional outbox. Reason: a PayEx timeout is genuinely ambiguous.
Something must retry. An idempotency key alone does not retry.

## Options Considered

### Option A - Idempotency Key + Dedupe Table

Pros:
- Simple design
- Lower implementation effort
- Minimal infrastructure changes

Cons:
- No automatic retry mechanism
- Ambiguous PayEx timeouts require manual investigation
- Higher risk of lost payments
- Weaker operational recovery

### Option B - Transactional Outbox + Background Worker

Pros:
- Durable payment intent
- Automatic retry capability
- Strong audit trail
- Lowest lost-payment risk
- Better support for recovery from failures

Cons:
- Highest implementation complexity
- Requires worker monitoring
- Additional operational overhead

### Option C - Optimistic Submit + Nightly Reconciliation

Pros:
- Simpler operational model
- Faster implementation
- Easier for engineers new to the codebase

Cons:
- Delayed recovery
- Payments may remain unresolved until reconciliation
- Higher duplicate-payment risk during recovery
- Less reliable than transactional outbox

## Team Considerations

Two engineers are new to the codebase.

I considered Option C because it offers a simpler operating model and avoids introducing a background worker.

However, given the payment domain, ambiguous PayEx timeouts, seven-year audit requirements, and upcoming SOC 2 audit, I determined that reliability and auditability outweigh implementation simplicity.

## Final Decision

Selected Option B: Transactional Outbox + Background Worker.

Reasoning:

- Lowest lost-payment risk.
- Durable payment intent stored before external delivery.
- Strongest auditability.
- Better support for recovery during failures.
- More suitable for a payment workflow where ambiguity cannot be treated as failure.

## Risks of the Selected Approach

- Worker could stop processing.
- Operational monitoring is required.
- Retry logic must be carefully implemented.
- Additional infrastructure and runbooks are needed.

## Operational Mitigations

- Worker heartbeat monitoring.
- Oldest pending outbox age alerts.
- Application Insights dashboards.
- Staging rehearsal before on-call rotation.
- Runbook for common failure scenarios.

## AI Reflection

### What I Kept

- Option A/B/C comparison.
- PayEx timeout analysis.
- Failure-mode analysis.
- Cost breakdown structure.

### What I Changed

- Evaluated recommendations against team skills and audit requirements.
- Added monitoring and operational mitigations.
- Selected Option B after reviewing reliability requirements.

### What Copilot Got Wrong

- Cost estimates are planning assumptions only.
- Actual throughput has not been measured.
- Azure pricing depends on region and configuration.
- PayEx idempotency support could not be verified.