# CLAUDE.MD -- Project Development with Claude Code

**Project:** [YOUR PROJECT NAME]
**Researcher:** Hengxu Lin
**Institution:** Columbia University
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/run and confirm output at the end of every task
- **Single source of truth** -- Beamer `.tex` is authoritative for slides; Python scripts/notebooks are authoritative for analysis
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
[YOUR-PROJECT]/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── preambles/header.tex         # LaTeX headers
├── slides/                      # Beamer .tex files
├── data/
│   ├── raw/                     # Raw input data (read-only)
│   └── processed/               # Cleaned/transformed data
├── output/                      # Figures, tables, reports (derived)
├── scripts/                     # Utility scripts
│   └── notebooks/               # Jupyter notebooks
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── related_work/                # Related papers/reports for references
└── templates/                   # Session log, quality report templates
```

---

## Example commands

```bash
# LaTeX (3-pass, XeLaTeX only)
cd Slides && TEXINPUTS=../preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
BIBINPUTS=..:$BIBINPUTS bibtex file
TEXINPUTS=../preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex
TEXINPUTS=../preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Python
python scripts/script_name.py
python -m pytest tests/
pip install -r requirements.txt   

# Jupyter
jupyter nbconvert --to notebook --execute notebooks/analysis.ipynb
jupyter notebook

# Code quality
black scripts/
ruff check scripts/
mypy scripts/

# Quality score
python scripts/quality_score.py slides/file.tex
python scripts/quality_score.py scripts/analysis.py
python scripts/quality_score.py notebooks/analysis.ipynb
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for review |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/context-status` | Show session health + context usage |
| `/create-slides` | Full presentation slides creation |
| `/data-analysis [dataset]` | End-to-end Python analysis |
| `/deep-audit` | Repository-wide consistency audit |
| `/devils-advocate` | Challenge document/co/design |
| `/interview-me [topic]` | Interactive research interview |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/lit-review [topic]` | Literature search + synthesis |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/review-python [file]` | Python code quality review |
| `/slide-review [file]` | Combined multi-agent review |
| `/review-paper [file]` | Manuscript review |

---

## Beamer Custom Environments

| Environment       | Effect        | Use Case       |
|-------------------|---------------|----------------|
| `[your-env]`      | [Description] | [When to use]  |

<!-- Example entries (delete and replace with yours):
| `keybox` | Gold background box | Key points |
| `highlightbox` | Gold left-accent box | Highlights |
| `definitionbox[Title]` | Blue-bordered titled box | Formal definitions |
-->

---

## Python Conventions

- **Style:** PEP 8, type hints, Google-style docstrings, `black`/`ruff` formatting
- **Reproducibility:** `numpy.random.seed()` / `random.seed()` / `torch.manual_seed()` at top; relative paths only; `requirements.txt` or `pyproject.toml`
- **Functions:** `snake_case`, explicit return types, single responsibility
- **Visualization:** 300 DPI for scientific figures, consistent color palette, `matplotlib` / `seaborn`
- **Notebooks:** restart-and-run-all must succeed; no hidden state; clear output before committing

---

## Active Projects

| Project | Slides | Analysis | Key Content |
|---------|--------|----------|-------------|
| [Topic] | slides/topic.tex` | `notebooks/topic.ipynb` | [Brief description] |
