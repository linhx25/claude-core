---
paths:
  - "Slides/**/*.tex"
  - "scripts/**/*.py"
  - "scripts/notebooks/**/*.ipynb"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For LaTeX/Beamer Slides (.tex):
1. Compile with xelatex (3-pass) and check for errors
2. Open the PDF to verify figures render (`open` on macOS, `xdg-open` on Linux)
3. Check for overfull hbox warnings
4. Verify all citations resolve (no undefined references)
5. Report verification results

## For Python Scripts (.py):
1. Run `python scripts/FILENAME.py` and check exit code (0 = success)
2. Verify output files were created in `output/` with non-zero size
3. Spot-check key output values for reasonable magnitude
4. Confirm no hardcoded absolute paths remain
5. Check that random seeds are set if stochastic operations are used

## For Jupyter Notebooks (.ipynb):
1. Execute full notebook: `jupyter nbconvert --to notebook --execute notebooks/FILENAME.ipynb --output notebooks/FILENAME.ipynb`
2. Check exit code (0 = success)
3. Verify all output cells populated correctly
4. Confirm output files written to `output/` directory
5. Check that notebook runs top-to-bottom without dependency on prior state

## Common Pitfalls:
- **Absolute paths:** Scripts with hardcoded `/Users/...` paths fail on other machines
- **Missing seeds:** Stochastic scripts without `random.seed()` produce non-reproducible results
- **Hidden notebook state:** Notebooks that require out-of-order execution fail restart-and-run-all
- **Output in wrong location:** Files written to ad-hoc paths instead of `output/` break reproducibility
- **Assuming success:** Always verify output files exist AND contain correct content

## Verification Checklist:
```
[ ] Output file created successfully
[ ] No compilation/execution errors
[ ] Figures/tables display correctly
[ ] Random seeds set (if stochastic)
[ ] All paths are relative
[ ] Reported results to user
```
