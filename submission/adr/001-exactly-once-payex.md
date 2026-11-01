# ADR-001: PayEx payment delivery and duplicate prevention
Status: Decision for planned target; implementation and provider guarantees unverified — 2026-10-31

## My position before Copilot
Transactional outbox with a stable provider idempotency key, if PayEx
supports the required semantics. A timeout is ambiguous: an idempotency
key alone does not retry, while a retry without provider deduplication
can create a duplicate payment.

## Options Considered

### Option A - Idempotency Key + Dedupe Table

Pros:
- Simple design
- Lower implementation effort
- Minimal infrastructure changes
- A unique local dedupe key can prevent duplicate internal payment intents.

Cons:
- A local dedupe table does not make the external PayEx operation exactly once.
- A timeout still leaves the outcome unknown; safe retry requires PayEx to
  honor the same idempotency key or provide an authoritative status lookup.
- Without a durable retry worker, an intent can remain unsent until an
  operator investigates.
- If PayEx does not support idempotency/status lookup, this option cannot
  guarantee both eventual delivery and no duplicate external effect.

### Option B - Transactional Outbox + Background Worker

Pros:
- Durable payment intent
- Automatic retry capability
- Strong audit trail
- Reduces lost-intent risk
- Better support for recovery from failures

Cons:
- Highest implementation complexity
- Requires worker monitoring
- Additional operational overhead
- Delivery is at-least-once; exactly-once external effect still depends on
  PayEx idempotency or authoritative status lookup.

### Option C - Optimistic Submit + Nightly Reconciliation

Pros:
- Simpler operational model
- Faster implementation
- Easier for engineers new to the codebase

Cons:
- Delayed recovery
- Payments may remain unresolved until reconciliation
- Reconciliation detects mismatches after the fact; it does not prevent
  duplicates or prove whether a timed-out request completed.
- Manual resolution can be risky during month-end volume and settlement
  deadlines.

## Team Considerations

Two engineers are new to the codebase.

I considered Option C because it offers a simpler operating model and avoids introducing a background worker.

However, given the payment domain, ambiguous PayEx timeouts, seven-year audit requirements, and upcoming SOC 2 audit, I determined that reliability and auditability outweigh implementation simplicity.

## Preference-reversal pressure test

When I explicitly preferred Option C because two engineers are new to the
codebase, Copilot treated C as conditionally reasonable with safeguards.
That is a shift from its initial preference for B, but it does not resolve
the ambiguous-timeout or duplicate-payment problem. I kept B as the human
decision; the changed recommendation is not evidence that C provides an
exactly-once guarantee. The prompt and recorded response summary are in
`submission/ai-logs/ai-augmentation-log.md`, Interaction 5.

## Final Decision

Selected Option B: Transactional Outbox + Background Worker, paired with a
stable provider idempotency key and reconciliation. This guarantees durable,
atomic recording of approval and payment intent in our database. It does not,
by itself, guarantee exactly-once delivery or exactly-once external payment.
Do not claim the external guarantee until PayEx's key scope, retention,
concurrent-request behavior, and status lookup are contractually verified
and tested.

Reasoning:

- Lowest risk of losing a recorded payment intent; does not remove external
  payment ambiguity.
- Durable payment intent stored before external delivery.
- Strongest auditability.
- Better support for recovery during failures.
- More suitable for a payment workflow where ambiguity cannot be treated as failure.

## What would make us revisit

- PayEx does not support stable idempotency keys for the full retry/recovery
  window and has no authoritative payment-status lookup.
- A contract, sandbox test, or production incident disproves the assumed
  key scope, retention, or duplicate-suppression behavior.
- Month-end volume or the settlement cutoff makes the selected retry and
  manual-review windows unsafe.
- Measured build or monthly run cost exceeds the approved budget.

Until provider behavior is verified, an ambiguous timeout enters `Unknown`
and is not blindly resubmitted. Resolve it through provider status inquiry
or manual review; the service must not promise the invoice was paid exactly
once.

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

## Where the agent was wrong or useless

- It framed Option B as the lowest lost-payment risk without making the
  provider idempotency guarantee a prerequisite. An outbox makes intent
  durable; it cannot force an external provider to deduplicate.
- It could not verify PayEx idempotency support, key retention, or status
  lookup. Those are decision-blocking facts, not implementation details.
- Its cost output was not retained as a component-level estimate or a
  priced monthly Azure bill in the final submission. The saved cost review
  contains only a broad 15-27 engineer-week planning range and unpriced
  cost drivers. Treat dollar estimates as unknown until deployment inputs
  and Azure pricing are available.

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
