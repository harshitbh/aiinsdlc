# Task 2 - 3AM Failure Analysis

## Month-end, last-day scenario

At 3 a.m. on the last working day of the month, the dispatcher stops making
progress while the PayEx key may have expired and the settlement cutoff is
approaching. In the stress-test scenario, one person is on call and up to
8,000 items may be waiting by the 9 a.m. peak. The database outbox preserves
approved payment intents, but payments may miss the cutoff. A timeout on an
in-flight call is ambiguous; blindly replaying it can duplicate a payment.

On-call actions:

1. Acknowledge the heartbeat/oldest-pending alert and check worker health,
   outbox age/count, recent attempts, and PayEx availability.
2. Stop accepting new payment approvals if the backlog or cutoff risk
   crosses the runbook threshold; do not delete or recreate outbox rows.
3. For each ambiguous attempt, query PayEx by the stored provider reference
   or idempotency key. Retry only with the same key and only while the
   provider's deduplication guarantee is valid.
4. Put unconfirmed/expired-key items into manual review; notify Finance of
   cutoff exposure and record the incident timeline.
5. Resume processing only after duplicate-suppression behavior is verified
   and the oldest pending age is recovering.

## Highest Risk Scenario

Worker process stopped silently while approvals continue to be accepted.

Impact:

- Approvals continue succeeding.
- Payments stop being delivered.
- Backlog grows overnight.
- Large number of invoices may remain pending before business hours.

Mitigation:

- Always On enabled.
- Worker heartbeat monitoring.
- Alert on oldest pending outbox item.
- Alert on pending item count.
- Runbook available for on-call engineer.

## Key Failure Modes Reviewed

- Worker process stopped silently.
- PayEx API key expired or rotated.
- Duplicate worker processing of the same outbox record.
- PayEx timeout with expired idempotency window.
- Large overnight backlog accumulation.

Conclusion:

Operational monitoring is mandatory for Option B. Most failure scenarios can be detected through heartbeat, backlog, retry, and authentication alerts before business hours begin.

**Scenario assumptions:** The 8,000-item backlog, prior key-rotation incident,
worker, PayEx, settlement cutoff, outbox, and alerts are supplied scenario
inputs, not observed current application behavior. The production plan is
described in `ops/README.md` and `submission/architecture/target-state.md`.