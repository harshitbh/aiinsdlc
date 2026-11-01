# Eval Results

## Setup

| Item | Detail |
|------|--------|
| Model | GitHub Copilot (auto) |
| Cases 01-10 | From ops/evals/cases/ (existing) |
| Case 11 | Added: missing [RequireRole("Admin")] on DeleteInvoice endpoint |
| Case 12 | Added: log statement recording only invoice ID (clean case) |
| Prompt v1 | submission/evals/prompt-v1.md |
| Prompt v2 | submission/evals/prompt-v2.md |
| Changed variable | One sentence added to v2: "handling financial transactions, subject to SOC 2 Type II audit in 6 months" |
| Runs 1-3 | Baseline — prompt-v1 |
| Run 4 | Changed variable — prompt-v2 |
| Runs 5-6 | Additional v2 runs for confirmation |

## Results Table

| Case | Expected | Run 1 (v1) | Run 2 (v1) | Run 3 (v1) | Run 4 (v2) |
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

## Rates

| Metric | Run 1 | Run 2 | Run 3 | v1 avg | Run 4 (v2) |
|--------|-------|-------|-------|--------|-----------|
| Caught (defects found / 9 total) | 9/9 (100%) | 9/9 (100%) | 9/9 (100%) | 100% | 9/9 (100%) |
| Missed (defects not found / 9) | 0/9 (0%) | 0/9 (0%) | 0/9 (0%) | 0% | 0/9 (0%) |
| False alarms (clean flagged / 3) | 0/3 (0%) | 0/3 (0%) | 0/3 (0%) | 0% | 0/3 (0%) |

## Was v2 an improvement?

No measurable improvement — and none was needed. The baseline prompt-v1 already achieved 100% catch rate and 0% false alarm rate across all 3 baseline runs and all 12 cases. Prompt-v2 produced identical results. The SOC 2 context sentence made one notable difference: in run 4 case-07, Copilot explicitly named the SOC 2 concern ("creating a SOC 2 concern") where runs 1-3 only noted "plausible exposure." This shows the additional context sharpened the framing of the finding without changing the verdict.

## Confidence Statement

12 cases × 3 baseline runs = 36 observations.
Defect cases: 9. Clean cases: 3.
The model caught every defect in every run with zero false alarms.
The ceiling effect (100% baseline) means v2 could not show improvement on catch rate. A harder eval set with ambiguous cases would be needed to distinguish v1 from v2 meaningfully.
At this sample size and with a perfect baseline, I cannot claim v2 is better — only that it is not worse, and that it produces more SOC 2-specific framing on data-exposure cases.

## Additional runs 5 and 6 (both v2)

Runs 5 and 6 confirmed the run 4 results exactly.
All 9 defect cases caught, all 3 clean cases clean across both additional runs. The model is highly consistent on these cases.
