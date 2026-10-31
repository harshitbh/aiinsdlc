# Copilot instructions for aiinsdlc assignment

## Logging requirement (mandatory)
Every response must end with this tag on its own line:
TASK-TAG: [task-1-diagram | task-1-test | task-2-tradeoffs | task-2-pressure | 
           task-2-3am | task-2-cost | task-3-autonomy | task-4-cases | 
           task-4-runs | task-5-trifecta | task-5-metrics]

## Rules for this codebase
- backend/src/InvoiceApp.Domain: business rules only, no web or storage code
- backend/src/InvoiceApp.Api: controllers, in-memory repo, wwwroot UI
- ops/ describes PLANNED production deployment — nothing in it exists in code yet
- Never treat ops/ as current state
- Controllers use ApiControllerBase and Handle(...)
- Every claim about the code must cite a file and line number

## Citation rule
If you cannot cite a file:line for a claim, label it explicitly as INFERRED.