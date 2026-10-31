# Task 2 - 3AM Failure Analysis

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