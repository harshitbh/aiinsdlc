# INFERRED

- The `User` actor and the act of sending an HTTP request are external to the inspected code. The route and controller action exist in code, but no user class or caller is defined in these files. The actor is included because the requested sequence begins with `User`.
- Azure SQL is a planned replacement for the registered in-memory repository; it is not present in the current code.
- The `PaymentSubmission` outbox table and atomic write with approval are target-state requirements, not implemented in the inspected code.
- The dispatcher `BackgroundService`, its outbox polling, retry behavior, and PayEx HTTP call are target-state requirements, not implemented in the inspected code.
- The PayEx HTTP API, 30-second timeout, and ambiguous-timeout behavior are supplied target assumptions, not represented by current code in the inspected files.
- A shared session store for three App Service instances is a target-state requirement; the current diagram does not establish such a store.
- The target graph's dashed connections describe intended future integration flows; they are not current method calls or implemented runtime connections.
