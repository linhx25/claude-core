# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)

---

## The Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Code ambiguity:** "Spec unclear on X. Assume Y?"
- **Replication edge case:** "Just missed tolerance. Investigate?"
- **Scope question:** "Also refactor Y while here, or focus on X?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (tests, compilation, notebook execution)
- Documentation (logs, commits)
- Plotting (per established standards)
- Analysis (after you approve the approach, I run it automatically)

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables (Customize These)

<!-- Replace with YOUR project's locked-in preferences -->

- **Paths:** Relative paths via `pathlib.Path`; never hardcode `/Users/...`
- **Seeds:** `random.seed(42)`, `np.random.seed(42)` once at top for stochastic code
- **Figures:** 300 DPI, explicit `figsize`, `bbox_inches='tight'`; `.pdf` + `.png`
- **Output:** All derived files go to `output/`; `data/raw/` is read-only
- **[YOUR COLOR PALETTE]:** e.g., institutional colors

---

## Python Toolchain

```bash
# Run script
python scripts/analysis.py

# Run tests
pytest tests/

# Format
black scripts/ notebooks/

# Lint
ruff check scripts/

# Type check
mypy scripts/

# Execute notebook
jupyter nbconvert --to notebook --execute notebooks/analysis.ipynb

# Install dependencies
pip install -r requirements.txt
```

---

## LaTeX Compilation

```bash
cd slides
TEXINPUTS=../preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
```

---

## Preferences

<!-- Fill in as you discover your working style -->

**Visual:** [How you want figures/plots handled]
**Reporting:** [Concise bullets? Detailed prose? Details on request?]
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** [How strict? Flag near-misses?]

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
