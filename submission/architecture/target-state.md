# Target state: once persistence and PayEx are in

Today, the application is an ASP.NET Core API with a static browser UI, `ApprovalService`, an in-memory invoice repository, and an in-memory bearer-session store. The target replaces volatile invoice storage with Azure SQL, commits approval/audit/payment intent together, and uses a background dispatcher to submit payments to PayEx. It also moves sessions to shared storage for three App Service instances and adds monitoring and daily reconciliation. **ADR-001: Exactly-once PayEx submission** selects Option B, the transactional outbox with a background worker; this is a target design, not implemented application behavior.

## Legend

- **Exists today** — present in application source now.
- **Exists and changes planned** — current component remains, but its implementation or hosting changes.
- **Planned / not built** — target component or behavior absent from current application code.
- **Provisioned but not used** — infrastructure is reported provisioned, but the selected target flow does not depend on it.
- **External dependency** — operated outside this application.

## Container view

```mermaid
flowchart LR
    subgraph Exists[Exists today]
        User[Approver or Admin]
        UI[Static web UI<br/>app.js]
        Controllers[InvoiceApp.Api controllers]
        Service[ApprovalService]
    end

    subgraph Changing[Exists and changes planned]
        AppService[Azure App Service<br/>3 instances]
        CurrentSessions[In-memory SessionStore]
        CurrentRepo[InMemoryInvoiceRepository]
    end

    subgraph Planned[Planned / not built]
        SharedSessions[Shared session store]
        SqlRepo[SqlInvoiceRepository]
        SQL[Azure SQL]
        Outbox[PaymentSubmission outbox table]
        Audit[ApprovalAudit table]
        Dispatcher[Dispatcher BackgroundService]
        Vault[Key Vault]
        Insights[Application Insights]
        Reconcile[Daily Reconciliation process]
    end

    subgraph Provisioned[Provisioned but not used]
        Bus[Azure Service Bus]
    end

    subgraph External[External]
        PayEx[PayEx API]
        Finance[Finance team]
    end

    User --> UI
    UI -->|HTTP requests| AppService
    AppService --> Controllers
    Controllers --> Service
    Service --> SqlRepo
    SqlRepo -->|transaction: invoice, audit, outbox| SQL
    Service -->|persist payment intent in same transaction| Outbox
    Outbox -->|poll and lease claims| Dispatcher
    Dispatcher -->|load API secret| Vault
    Dispatcher -->|payment request, stable idempotency key| PayEx
    Dispatcher -->|heartbeat, attempts, outcomes, backlog| Insights
    Reconcile -->|read invoice, audit, outbox state| SQL
    Reconcile -->|compare payment status| PayEx
    Reconcile -->|unresolved exceptions and daily report| Finance

    AppService -.->|replace per-process sessions| SharedSessions
    SharedSessions -.-> AppService
    CurrentSessions -.->|replaced by| SharedSessions
    CurrentRepo -.->|replaced by| SqlRepo

    classDef exists fill:#d9ead3,stroke:#38761d,color:#000
    classDef changing fill:#fff2cc,stroke:#bf9000,color:#000
    classDef planned fill:#fce5cd,stroke:#e69138,stroke-dasharray:5 5,color:#000
    classDef provisioned fill:#d9d2e9,stroke:#674ea7,color:#000
    classDef external fill:#d9eaf7,stroke:#3d85c6,color:#000

    class User,UI,Controllers,Service exists
    class AppService,CurrentSessions,CurrentRepo changing
    class SharedSessions,SqlRepo,SQL,Outbox,Audit,Dispatcher,Vault,Insights,Reconcile planned
    class Bus provisioned
    class PayEx,Finance external
```

The Service Bus is shown as provisioned but unused and intentionally has no message-flow arrows: the selected design has the dispatcher poll and claim SQL outbox rows. No Service Bus dependency is assumed for this target.

## Container Citation Table

| Element | Status | Source | Design rationale |
|---|---|---|---|
| Static web UI | Exists | `backend/src/InvoiceApp.Api/wwwroot/app.js`; `backend/src/InvoiceApp.Api/wwwroot/index.html` | Existing browser client presents invoices and submits approval requests. |
| InvoiceApp.Api controllers | Exists | `backend/src/InvoiceApp.Api/Controllers/InvoicesController.cs`; `ApprovalsController.cs`; `AuthController.cs` | Existing HTTP boundary; retained for the target workflow. |
| ApprovalService | Exists | `backend/src/InvoiceApp.Domain/ApprovalService.cs` | Existing domain service owns submit/approve/reject transitions. ADR-001 keeps approval rules in the domain while delivery becomes asynchronous. |
| In-memory SessionStore | Exists and changes planned | `backend/src/InvoiceApp.Api/Auth/SessionStore.cs`; `Program.cs` registers it singleton | Current process-local token store is not shared across instances; replace with a shared store for the three-instance target. |
| InMemoryInvoiceRepository | Exists and changes planned | `backend/src/InvoiceApp.Api/InMemoryInvoiceRepository.cs`; `Program.cs` registration | Current volatile repository is replaced by SQL persistence. |
| Azure App Service, 3 instances | Planned / not built | Target requirements supplied for this architecture; not established by current app code | Runs multiple API instances for the production deployment target. |
| Shared session store | Planned / not built | Target requirements; no current shared-store implementation | Keeps authentication sessions available across App Service instances. Specific product is intentionally unspecified. |
| SqlInvoiceRepository | Planned / not built | Target requirements; current repository is in-memory | Implements the existing repository abstraction against Azure SQL. |
| Azure SQL | Planned / not built | ADR-001, “Option B” and “Final Decision”; target requirements | Durable invoice, audit, and outbox persistence; provides the transaction boundary for approval intent. |
| PaymentSubmission outbox table | Planned / not built | ADR-001, “Option B - Transactional Outbox + Background Worker”; target requirements | Stores payment intent atomically with the approval and audit update, so delivery can resume after process failure. |
| ApprovalAudit table | Planned / not built | Target requirements; ADR-001’s seven-year auditability rationale | Persists approval decisions for audit retention. Table schema and retention implementation remain to be designed. |
| Dispatcher BackgroundService | Planned / not built | ADR-001, “Option B - Transactional Outbox + Background Worker”; target requirements | Claims and delivers pending outbox work with retry and operational monitoring. |
| PayEx API | External dependency | ADR-001, “Options Considered” and “Risks of the Selected Approach”; target requirements | External payment provider. Timeout is ambiguous; use provider idempotency/status capabilities before retrying uncertain outcomes. Support is not verified in the ADR. |
| Key Vault | Planned / not built | Target requirements; no current application integration | Stores the PayEx credential outside application source/configuration. |
| Application Insights | Planned / not built | ADR-001, “Operational Mitigations”; target requirements | Provides worker heartbeat, backlog-age, attempt, and outcome telemetry/alerts. |
| Daily Reconciliation process | Planned / not built | Target requirements; ADR-001 identifies ambiguous outcomes and recovery risk | Compares SQL payment records with PayEx status and reports unresolved differences to Finance. |
| Finance team | External | Target requirements | Receives exceptions and reconciliation reports for operational resolution. |
| Azure Service Bus | Provisioned but not used | `ops/incidents/INC-2047/servicebus-status.txt`; `ops/README.md` scenario note | Existing scenario evidence reports a provisioned topic. The chosen SQL-polling outbox design does not use it. |

## Sequence: approving an invoice

```mermaid
sequenceDiagram
    autonumber
    actor Approver
    participant Controller as ApprovalsController
    participant Service as ApprovalService
    participant Repository as SqlInvoiceRepository
    participant SQL as Azure SQL
    participant Dispatcher as Dispatcher BackgroundService
    participant PayEx as PayEx API
    participant Vault as Key Vault
    participant Insights as Application Insights
    participant Reconcile as Daily Reconciliation
    participant Finance as Finance team

    Approver->>Controller: Approve invoice
    Controller->>Service: Call Approve with invoice id and approver
    Service->>Repository: Save approval transaction
    Repository->>SQL: Begin transaction
    Repository->>SQL: Update invoice status and decision fields
    Repository->>SQL: Insert ApprovalAudit row
    Repository->>SQL: Insert PaymentSubmission outbox row and stable key
    Repository->>SQL: Commit transaction
    Repository-->>Service: Commit successful
    Service-->>Controller: Approved invoice
    Controller-->>Approver: HTTP 200 approval accepted without waiting for PayEx

    loop Poll and lease available outbox work
        Dispatcher->>SQL: Claim eligible outbox row with lease
        SQL-->>Dispatcher: Claimed payment intent
        Dispatcher->>Vault: Read PayEx credential
        Vault-->>Dispatcher: Credential
        Dispatcher->>PayEx: Submit payment with stored idempotency key
        alt PayEx confirms success
            PayEx-->>Dispatcher: Success and provider reference
            Dispatcher->>SQL: Mark outbox succeeded and persist provider reference
            Dispatcher->>Insights: Record success and processing latency
        else PayEx validation failure
            PayEx-->>Dispatcher: Validation response
            Dispatcher->>SQL: Mark terminal failure or manual-review state
            Dispatcher->>Insights: Record failure and alert
        else PayEx timeout outcome unknown
            PayEx-->>Dispatcher: No definitive response before timeout
            Dispatcher->>SQL: Mark outcome Unknown and retain same idempotency key
            Dispatcher->>Insights: Record timeout and alert
            alt Key is still valid and retry is safe
                Dispatcher->>SQL: Schedule retry using same key
            else Key expired or outcome cannot be confirmed
                Dispatcher->>SQL: Stop blind retries and mark manual review
                Dispatcher->>Insights: Alert on unresolved payment
            end
        else Retryable transport failure
            PayEx-->>Dispatcher: Transient failure
            Dispatcher->>SQL: Schedule bounded retry with backoff and same key
            Dispatcher->>Insights: Record attempt and retry state
            alt Retry limit exhausted
                Dispatcher->>SQL: Mark dead letter for manual review
                Dispatcher->>Insights: Alert on terminal backlog item
            end
        end
    end

    Reconcile->>SQL: Read approvals, audit, and outbox states
    Reconcile->>PayEx: Query provider status by stable reference/key
    PayEx-->>Reconcile: Provider payment status
    Reconcile->>SQL: Record reconciliation result
    Reconcile-->>Finance: Daily report and unresolved exceptions
```

**Exactly-once boundary:** the SQL transaction makes the invoice decision, audit row, and outbox intent atomic. Delivery is retried and therefore may be at-least-once. Avoiding duplicate external payment effects depends on PayEx honoring the stable idempotency key or providing a status lookup; ADR-001 says PayEx support could not yet be verified. Do not blindly retry an ambiguous timeout after the provider’s key-retention window expires.

## What changes compared with today

| Today | Target state |
|---|---|
| `InMemoryInvoiceRepository` loses data on process restart | `SqlInvoiceRepository` persists invoice state in Azure SQL |
| In-memory `SessionStore` is local to one process | Shared session store serves all three App Service instances |
| Approval only changes invoice state in the current repository | Approval, `ApprovalAudit`, and `PaymentSubmission` outbox row commit in one SQL transaction |
| In-memory single-process assumptions | Lease-based SQL claims and shared persistence coordinate multiple instances |
| No persistent approval audit table in current code | `ApprovalAudit` stores approval decisions for the required retention period |
| No payment reconciliation process in current code | Daily reconciliation compares SQL state with PayEx and reports exceptions |
| No PayEx request in current code | Background dispatcher submits payment requests asynchronously after approval commits |

## Risks Removed

- **Lost data on restart:** durable invoice, audit, and payment-intent rows survive API process restarts.
- **Concurrent approvals:** SQL transaction/locking and lease-based work claims are designed to coordinate concurrent instances; isolation and conflict behavior still require implementation and tests.
- **Duplicate payment submission:** a stable idempotency key plus provider confirmation/reconciliation reduces duplicate effects; exactly-once external effects are not guaranteed until PayEx behavior is confirmed.
- **Session loss between instances:** shared session storage makes a session available to all instances, subject to the selected store's availability and consistency design.
- **External dependency latency:** the approval response no longer waits for PayEx; the outbox preserves the work for asynchronous delivery. PayEx delays still affect payment completion time.

## Architecture Principles

- **Domain isolation:** business transitions remain in `InvoiceApp.Domain`; API, SQL, and PayEx adapters stay outside the domain assembly.
- **Repository abstraction:** `IInvoiceRepository` remains the domain-facing persistence contract; the planned SQL repository implements it.
- **Dependency injection:** register SQL repository, dispatcher, clients, and shared-session integration through the host's service container rather than constructing them in controllers.
- **Transaction boundaries:** invoice update, audit insert, and outbox insert use one Azure SQL transaction. External PayEx calls happen after commit, never inside that transaction.
- **Exactly-once submission strategy:** durable outbox plus stable provider idempotency key and reconciliation. The database guarantees durable intent; external exactly-once behavior depends on PayEx semantics and must be verified.
- **Observability:** worker heartbeat, oldest pending age, Unknown count, attempt outcomes, and reconciliation exceptions feed Application Insights and actionable alerts.
