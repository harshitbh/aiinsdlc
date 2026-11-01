# Eval Results

> **Evidence status:** The result values below are the previously reported
> outcomes, not independently verified run records. `submission/evals/eval-runs.csv`
> is absent, and the saved raw session contains prompts but not all 72 model
> responses. The added case artifacts have been reconciled to their prompts
> after the reported runs; rerun all cases and save each response before
> presenting these rates as verified results.

## Setup

| Item | Detail |
|------|--------|
| Model | GitHub Copilot (auto) |
| Cases 01-10 | From ops/evals/cases/ (existing) |
| Case 11 | Added: audit-trail endpoint returns decision fields without Admin authorization |
| Case 12 | Added: ID-only submission log statement (clean case) |
| Prompt v1 | submission/evals/prompt-v1.md |
| Prompt v2 | submission/evals/prompt-v2.md |
| Changed variable | One sentence added to v2: "handling financial transactions, subject to SOC 2 Type II audit in 6 months" |
| Runs 1-3 | Baseline — prompt-v1 |
| Run 4 | Changed variable — prompt-v2 |
| Runs 5-6 | Additional v2 runs for confirmation |

## Results Table

| Case | Expected | Run 1 (v1, reported) | Run 2 (v1, reported) | Run 3 (v1, reported) | Run 4 (v2, reported) |
|------|----------|-----------|-----------|-----------|-----------|
| 01 | catch | caught | caught | caught | caught |
| 02 | catch | caught | caught | caught | caught |
| 03 | catch | caught | caught | caught | caught |
| 04 | clean | clean | clean | clean | clean |
| 05 | catch | caught | caught | caught | caught |
| 06 | clean | clean | clean | clean | clean |
| 07 | catch | caught | caught | caught | caught |
| 08 | catch | caught | caught | caught | caught |
| 09 | catch | caught | caught | caught | caught |
| 10 | catch | caught | caught | caught | caught |
| 11 | catch | caught | caught | caught | caught |
| 12 | clean | clean | clean | clean | clean |

## Reported rates (unverified)

| Metric | Run 1 | Run 2 | Run 3 | v1 avg | Run 4 (v2) |
|--------|-------|-------|-------|--------|-----------|
| Caught (defects found / 9 total) | 9/9 (100%) | 9/9 (100%) | 9/9 (100%) | 100% | 9/9 (100%) |
| Missed (defects not found / 9) | 0/9 (0%) | 0/9 (0%) | 0/9 (0%) | 0% | 0/9 (0%) |
| False alarms (clean flagged / 3) | 0/3 (0%) | 0/3 (0%) | 0/3 (0%) | 0% | 0/3 (0%) |

## Was v2 an improvement?

The reported table shows no measurable improvement: the reported results are identical. Because the run-by-run responses and the exact submitted diffs are not retained, this is a provisional account, not a verified comparison. The claimed case-07 SOC 2 framing difference is likewise unverified.

## Confidence Statement

12 cases × 3 baseline runs = 36 claimed observations.
Defect cases: 9. Clean cases: 3.
The supplied summary says the model caught every defect in every run with
zero false alarms, but the missing responses and CSV mean that neither the
rates nor the ceiling effect can be independently verified. Do not claim
confidence from the nominal sample size until the runs are reproduced and
recorded.

## Additional runs 5 and 6 (both v2)

The supplied summary says runs 5 and 6 matched run 4 (9/9 defects caught,
0/3 clean cases flagged in each run). These outcomes are also unverified;
their rows are not present in the workspace.

## Reproduction required

Run cases 01-12 individually against prompt-v1 three times, then against
prompt-v2 once, holding model and context constant. Record the exact prompt,
case revision, response, verdict, and timestamp in `eval-runs.csv`. Only
then calculate per-run caught, missed, and false-alarm rates from that CSV.
