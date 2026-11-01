# Task 2 Cost Review

## Estimate Confidence

Confidence Level: Low for dollar costs; planning-level for engineering effort.

The saved decision record supports only a broad 15-27 engineer-week estimate
for Option B. A component-by-component estimate and monthly Azure dollar
total were not retained, so neither should be represented as measured or
approved cost.

Assumptions:

- Azure SQL sizing has not yet been validated.
- Actual invoice row size is unknown.
- Production telemetry volumes are unknown.
- PayEx traffic patterns may differ from current assumptions.
- Azure pricing varies by region and subscription agreement.
- Region, SKU, redundancy, backup/retention policy, log ingestion, and
  deployment topology are not specified.

## Engineering Estimate Review

The estimated effort range of 15-27 engineer-weeks appears reasonable for:

- SQL migration
- Outbox implementation
- Worker development
- Monitoring
- Reconciliation process
- Performance testing
- Operational readiness

This is a planning estimate, not a quote. Build labor cost is:

`15-27 engineer-weeks x the team's loaded weekly engineering cost`

The estimate includes the work above but the saved evidence does not allocate
those weeks by component or give a comparable estimate for Options A and C.
Do not infer component estimates from the aggregate.

## Monthly run-cost estimate

No defensible monthly dollar amount can be calculated from the information
currently saved. The recurring-cost model for Option B is:

`Azure SQL + App Service (Always On) + Key Vault + Application Insights
+ backups/retention + network/egress + support/on-call labor`

The planning workload was 40,000 rows/month and seven-year retention, but
SQL sizing, region, redundancy, log volume, traffic, and subscription
discounts are unknown. Request an Azure Pricing Calculator estimate after
those inputs are agreed, then validate actual cost from the first month of
telemetry. Option A has lower worker/monitoring cost but higher manual
recovery effort; Option C has lower initial implementation effort but
potentially higher reconciliation and incident labor. These are relative
cost drivers, not priced comparisons.

## Conclusion

The saved 15-27 engineer-week estimate is sufficient only for rough
architectural sizing. It is not a final budget. The monthly run cost and
comparative option costs remain unpriced until Azure configuration and
workload inputs are confirmed.