# AI Augmentation Log

**Tool:** GitHub Copilot (auto model)  
**Repo:** harshitbh/aiinsdlc  
**Hook config:** .github/hooks/ai-augmentation.json  
**Raw events:** submission/ai-logs/raw-session.jsonl  
**Started:** 2026-10-31  

Configured hook commands append raw events to `raw-session.jsonl` when the Copilot hook runtime runs them.
This Markdown file is a compiled human-readable summary; the hook commands do not write to it directly.

## Task 1

- Count of prompts tagged `task-1-diagram` or `task-1-test`: unavailable; `submission/ai-logs/raw-session.jsonl` is missing.
- Tools used: unavailable; source event log is missing.
- Timestamps (first to last): unavailable; source event log is missing.

### Task 1 Prompt Conversation

The following are the five Task 1 prompts supplied by the user. This is a manually supplied prompt record, not a reconstruction from the missing raw hook log.

#### Prompt 1 - Read the codebase

Read these files and tell me exactly what exists in the code right now:
- `backend/src/InvoiceApp.Domain/` (all .cs files)
- `backend/src/InvoiceApp.Api/Controllers/` (all .cs files)
- `backend/src/InvoiceApp.Api/Program.cs`

For each class and public method you find, cite: filename:line.
List separately anything you cannot find in the files - label it INFERRED.
Do NOT mention PayEx, database, or Service Bus - those are in ops/ which is planned only.

TASK-TAG: task-1-diagram

#### Prompt 2 - As-built diagram

Using only what you just read from the code (no inference), produce:

1. A Mermaid container diagram (C4 style) of what exists RIGHT NOW.
	- Every node must cite filename:line
	- Every arrow must be justified by an actual method call you saw
	- Style: graph TD

2. A Mermaid sequence diagram of the approval path:
	User -> Controller -> ApprovalService -> Repository
	Cite the method name and file for each step.

3. A list headed INFERRED: of anything you added that you cannot cite.

Save the as-built diagram to: `submission/architecture/as-built.mmd`
Save the inferred list to: `submission/architecture/inferred.md`

TASK-TAG: task-1-diagram

#### Prompt 3 - Target state diagram

Now draw the TARGET state for January production.
These are additions - none exist in code today:
- Azure SQL (replaces InMemoryInvoiceRepository)
- PaymentSubmission outbox table (written atomically with approval)
- Dispatcher BackgroundService (polls outbox, calls PayEx)
- PayEx HTTP API (30s timeout, ambiguous on timeout)
- Shared session store (3 App Service instances break in-memory sessions)

Rules:
- Mark every new element with :::notBuilt
- Add: classDef notBuilt stroke-dasharray:5 5,fill:#fff3cd
- Elements from the as-built diagram stay as-is, no :::notBuilt
- Save to: `submission/architecture/target.mmd`

TASK-TAG: task-1-diagram

#### Prompt 4 - Architecture test

Write a single xUnit test file for this project.
Rule to enforce: InvoiceApp.Domain must not reference InvoiceApp.Api or Microsoft.AspNetCore.

Requirements:
- File: `backend/tests/InvoiceApp.Tests/ArchitectureTests.cs`
- Use reflection only, no external libraries (no NetArchTest, no ArchUnitNET)
- Attribute: [Trait("Category", "Architecture")]
- Load Domain assembly via: typeof(InvoiceApp.Domain.ApprovalService).Assembly
- Check GetReferencedAssemblies() for names starting with "InvoiceApp.Api" or "Microsoft.AspNetCore"
- On failure: Assert message must list the violating assembly names
- First line of file must be a comment: // RUN: dotnet test backend/InvoiceApp.sln --filter "Category=Architecture"
- Write the file now, then tell me the exact command to run it

TASK-TAG: task-1-test

#### Prompt 5 - Compile Task 1 log

Run the log-compiler subagent now.
Read `submission/ai-logs/raw-session.jsonl`.
Find all entries with task tag task-1-diagram or task-1-test.
Append a Task 1 section to `submission/ai-logs/ai-augmentation-log.md` with:
- Count of prompts
- List of tools used
- Timestamps (first to last)
- Leave blank fields: "What I kept:", "What I changed:", "What it got wrong:"

TASK-TAG: task-1-diagram

What I kept:

What I changed:

What it got wrong:

## Task 2

- Prompt count: 5 raw prompt entries matched the requested tags: `task-2-tradeoffs` (2 entries, including this log-compilation request), `task-2-pressure` (1), `task-2-3am` (1), and `task-2-cost` (1). This is 4 decision prompts plus 1 compilation prompt.
- Tools used during the Task 2 response window: `fetch_webpage` (4 calls). Tool events do not carry task tags; these calls occurred after the Task 2 cost prompt and before the compilation request.
- Recommendation under pressure: Yes, conditionally. The initial recommendation was B. In response to `task-2-pressure`, the answer said C could be a reasonable initial release if specific controls were added. After the user selected B, the subsequent response returned to B with worker monitoring and runbook conditions.
- Matching prompt timestamps: first `2026-10-31T09:16:19.067Z`; last `2026-10-31T09:29:03.376Z`.

What I kept:

- Comparison of Option A, B, and C.
- Analysis of PayEx timeout behavior.
- 3AM operational failure scenarios.
- Initial cost estimation breakdown.

What I changed:

- Selected Option B after reviewing business requirements.
- Added operational safeguards and monitoring recommendations.
- Included team capability considerations in the final decision.

What it got wrong:

- Azure cost estimates were assumptions.
- Throughput and backlog recovery rates were estimated.
- PayEx capabilities could not be verified from available information.
- Calendar effort estimates were not validated against actual team velocity.
