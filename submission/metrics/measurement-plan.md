# Baseline Measurement Plan

**Captured:** 2026-11-01
**Repository:** `harshitbh/aiinsdlc`

Capture these measures immediately before the rotation, then report the
measurement window and sample size with every comparison.

| Metric | Definition | Source and query | Baseline |
|---|---|---|---|
| Lead time for changes | Median elapsed time from PR creation to merge for merged changes | GitHub PR API; `gh pr list -R harshitbh/aiinsdlc --state merged --limit 100 --json number,title,createdAt,mergedAt` | Not calculable: query returned no merged PRs (0 observations). |
| Change failure rate | Production deployments that cause a production incident, rollback, or urgent hotfix divided by total production deployments in the same window | Production deployment history plus incident/rollback records. The only checked-in workflow is `.github/workflows/ci.yml`, which builds and tests but does not deploy. Do not substitute CI test failures. | Not measurable from current data. |
| Review turnaround | Median elapsed time from PR creation to first submitted review | For each PR: `gh pr view <number> -R harshitbh/aiinsdlc --json number,createdAt,reviews --jq '{number,createdAt,firstReviewAt:([.reviews[]?.submittedAt] | sort | .[0])}'` | Not calculable: no review history was available at capture time. |

## Captured today

The raw PR query returned `[]`; lead time is not zero, it is unavailable
because there were no observations. The raw Actions query returned 15
successful workflow runs and zero failed runs. That is a **CI workflow-run
failure rate of 0/15 (0%)**, not the deployment-based change failure rate
defined above. The raw outputs are preserved in
[`lead-time-raw.txt`](./lead-time-raw.txt),
[`ci-runs-raw.txt`](./ci-runs-raw.txt), and summarized in
[`baseline-captured.md`](./baseline-captured.md).

## Exact capture commands

```powershell
gh pr list -R harshitbh/aiinsdlc --state merged --limit 100 --json number,title,createdAt,mergedAt
gh run list -R harshitbh/aiinsdlc --limit 30 --json databaseId,conclusion,createdAt,displayTitle
gh pr list -R harshitbh/aiinsdlc --state all --limit 100 --json number
```

For review turnaround, run the `gh pr view` query above for each returned PR
number and compute the median of `firstReviewAt - createdAt`, excluding PRs
without a submitted review and reporting that excluded count. Current CI
history cannot supply the deployment denominator or incident-linked
deployment numerator for change failure rate. The only present CI query is
the second command above; it returns workflow outcomes, not deployment
outcomes. Once a production deployment workflow and incident links exist,
query its run records for the same window and join them to incident/rollback
records; report the deployment-query filter, incident source, and denominator
with the result. There is no valid current deployment query to report.
