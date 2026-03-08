---
paths:
  - "scripts/**/*.py"
  - "scripts/notebooks/**/*.ipynb"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

---

## Phase 1: Inventory & Baseline

Before writing any code:

- [ ] Read the paper's replication README
- [ ] Inventory replication package: language, data files, scripts, outputs
- [ ] Record gold standard numbers from the paper:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Main estimate | Table 2, Col 3 | -1.632 | (0.584) | Primary specification |
```

- [ ] Store targets in `quality_reports/[paper]_replication_targets.md`

---

## Phase 2: Translate & Execute

- [ ] Follow `python-code-conventions.md` for all coding standards
- [ ] Translate line-by-line initially — don't "improve" during replication
- [ ] Match original specification exactly (model, sample, standard errors)
- [ ] Save all intermediate results as `.pkl`, `.parquet`, or `.csv`

### Common Translation Pitfalls

<!-- Customize: Add pitfalls specific to your field and original software -->

| Original | Python | Trap |
|----------|--------|------|
| Stata `reg y x, cluster(id)` | `statsmodels` / `linearmodels` | Degrees-of-freedom adjustment may differ |
| R `feols(y ~ x \| id)` | `pyfixest` | Verify demeaning method matches |
| MATLAB random draws | `numpy.random` | Match seed convention and distribution parameterization |
| Bootstrap with `reps(999)` | `sklearn` / manual | Match seed, reps, and bootstrap variant exactly |

---

## Phase 3: Verify Match

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Integers (N, counts) | Exact match | No reason for any difference |
| Point estimates | < 0.01 | Rounding in paper display |
| Standard errors | < 0.05 | Bootstrap/clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Percentages | < 0.1pp | Display rounding |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample size, SE computation, default options, variable definitions), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/[paper]_replication_report.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Original language:** [python/MATLAB/etc.]
**Python translation:** [script path]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- Python version, key packages (with versions), data source
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication script: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with project-specific modifications (different estimators, new figures, etc.)
- [ ] Each extension builds on the verified baseline

---

## Python-Specific Pitfalls

- **Float precision:** `pandas` may display different decimal places than Stata output — compare rounded values
- **NA handling:** Python `NaN` propagation differs from Stata missing values (`.`)
- **Index alignment:** `pandas` aligns on index — ensure indices match before operations
- **Package versions:** Pin exact versions (`pip freeze > requirements.txt`) since APIs change
