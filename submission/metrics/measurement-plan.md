## Baseline Captured on 2026-11-01

# Baseline Capture Summary

| Metric | Status | Current Value | Evidence |
|----------|----------|----------|----------|
| Lead Time for Changes | Not measurable | No merged PRs | gh pr list returned [] |
| Change Failure Rate | Captured | 0% (0 failures / 15 runs) | GitHub Actions history |
| Review Turnaround | Not measurable | No review history | No PR reviews available |

### Lead Time for Changes

Command:

gh pr list --state merged --limit 20 --json number,title,createdAt,mergedAt

Result:

- No merged pull requests found (`[]`).
- Lead time cannot be calculated from repository history today.

Explanation:

The repository does not yet contain merged PR history, so there is no creation-to-merge data available.

### Change Failure Rate

Command:

gh run list --limit 30 --json databaseId,conclusion,createdAt,displayTitle

Result:

- Total workflow runs examined: 15
- Successful runs: 15
- Failed runs: 0

Calculation:

Change Failure Rate = Failed Runs / Total Runs

= 0 / 15

= 0%

Observation:

Current CI history shows a 0% failure rate across the available workflow runs.

### Review Turnaround

Status:

Not measurable today.

Reason:

No pull request review history exists in the repository.

Required data:

- PR creation timestamp
- First review timestamp

These data points will become available once pull requests and reviews are used in the development workflow.