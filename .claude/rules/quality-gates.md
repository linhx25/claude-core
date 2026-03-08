---
paths:
  - "Slides/**/*.tex"
  - "scripts/**/*.py"
  - "scripts/notebooks/**/*.ipynb"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## Beamer Slides (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |
| Major | Text overflow | -5 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 per slide |

## Python Scripts (.py)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Critical | Import error / missing package | -15 |
| Major | Missing random seed (when stochastic code present) | -10 |
| Major | No output files generated | -5 |
| Major | Function missing type annotations | -3 |
| Minor | PEP 8 / black formatting violations | -1 per violation |
| Minor | Missing docstring on public function | -1 |

## Jupyter Notebooks (.ipynb)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Restart-and-run-all fails | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Hidden state (out-of-order execution required) | -15 |
| Major | Missing random seed (when stochastic code present) | -10 |
| Major | Output not written to output/ directory | -5 |
| Minor | Cells without explanatory Markdown context | -2 |
| Minor | Committed with non-empty cell outputs (no nbstripout) | -1 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Research)

<!-- Customize for your domain -->

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | [e.g., 1e-6] | [Numerical precision] |
| Standard errors | [e.g., 1e-4] | [MC variability] |
| Coverage rates | [e.g., +/- 0.01] | [MC with B reps] |
