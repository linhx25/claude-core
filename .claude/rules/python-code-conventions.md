---
paths:
  - "scripts/**/*.py"
  - "scripts/notebooks/**/*.ipynb"
---

# Python Code Conventions

## Style

- **PEP 8:** Format with `black`; lint with `ruff`; type-check with `mypy`
- **Type hints:** All function signatures must have type annotations
- **Docstrings:** Google-style for all public functions and classes
- **Naming:** `snake_case` for functions/variables; `PascalCase` for classes; `UPPER_SNAKE` for module-level constants
- **Imports:** stdlib → third-party → local, separated by blank lines; never use `import *`
- **Line length:** 88 characters (black default); math formulas in comments may exceed this

## Reproducibility

- **Random seeds:** Set at top of script, before any stochastic calls:
  ```python
  import random, numpy as np
  random.seed(42)
  np.random.seed(42)
  # if using torch: torch.manual_seed(42)
  ```
- **Paths:** Use relative paths from project root; never hardcode absolute paths
  ```python
  from pathlib import Path
  ROOT = Path(__file__).parent.parent  # scripts/ → project root
  DATA = ROOT / "data" / "raw"
  OUTPUT = ROOT / "output"
  ```
- **Environment:** Pin dependencies in `requirements.txt` or `pyproject.toml`; include Python version

## Function Design

- **Single responsibility:** One function does one thing
- **Explicit returns:** Always annotate return type; never return `None` implicitly from non-void functions
- **No side effects** in pure computation functions; separate I/O from logic
- **Short functions:** If a function exceeds ~40 lines, split it

## Script Structure

```python
#!/opt/homebrew/bin/python3
"""
One-line description.

Inputs:  data/raw/input.csv
Outputs: output/figures/fig1.pdf, output/tables/table1.tex
"""

# 0. Imports ------------------------------------------------------------------
import random
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# 1. Constants ----------------------------------------------------------------
random.seed(42)
np.random.seed(42)

ROOT = Path(__file__).parent.parent
DATA = ROOT / "data" / "raw"
OUTPUT = ROOT / "output"
OUTPUT.mkdir(parents=True, exist_ok=True)

# 2. Data loading -------------------------------------------------------------

# 3. Analysis -----------------------------------------------------------------

# 4. Output -------------------------------------------------------------------
```

## Visual Conventions

- **DPI:** `dpi=300` for all publication figures (`savefig(..., dpi=300)`)
- **Format:** Save as both `.pdf` (vector, for LaTeX inclusion) and `.png` (raster, for notebooks)
- **Size:** Set explicit `figsize=(width, height)` in inches
- **Labels:** Axis labels in sentence case with units; no title inside the figure (use caption)
- **Transparency:** `bbox_inches='tight'` and `transparent=True` for Beamer-compatible figures
- **Color palette:** [YOUR_PALETTE] — define a project palette constant if used across scripts

## Notebook Conventions

- **Restart-and-run-all:** Every notebook must execute top-to-bottom without error after kernel restart
- **No hidden state:** Do not depend on variables set by previously-run-but-not-shown cells
- **Clear outputs before commit:** Keep notebooks clean in version control (or use `nbstripout`)
- **Cell order matters:** Cells must be ordered; avoid out-of-order execution
- **Markdown context:** Every analysis section should start with a Markdown cell explaining what's happening

## Output Organization

```
output/
├── figures/          # Publication-quality figures (.pdf, .png)
├── tables/           # Tables (.tex, .csv)
├── diagnostics/      # EDA plots (may be lower quality)
└── models/           # Saved model objects (.pkl, .joblib)
```

## Quality Checklist

Before committing any Python script:
```
[ ] black formatting passes
[ ] ruff lint passes (no warnings)
[ ] mypy type check passes
[ ] No hardcoded absolute paths
[ ] Random seeds set at top
[ ] All outputs written to output/ with explicit paths
[ ] Script runs from scratch (no dependency on session state)
[ ] requirements.txt / pyproject.toml updated if new packages added
```

Before committing any notebook:
```
[ ] Restart kernel → Run all → No errors
[ ] No cells with hidden state
[ ] Outputs saved to output/ (not just inline)
[ ] Markdown cells explain each analysis section
[ ] Clear outputs OR use nbstripout
```
