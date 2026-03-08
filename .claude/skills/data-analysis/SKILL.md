---
name: data-analysis
description: End-to-end Python data analysis workflow from exploration through modeling to publication-ready tables and figures
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis Workflow

Run an end-to-end data analysis in Python: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path (e.g., `data/raw/data.csv`) or a description of the analysis goal (e.g., "regress y on X").

---

## Constraints

- **Follow Python conventions** in `.claude/rules/python-code-conventions.md`
- **Save all scripts** to `scripts/` with descriptive names
- **Save all outputs** (figures, tables, processed data) to `output/`
- **Use relative paths** — all paths relative to project root via `pathlib.Path`
- **Run python-reviewer** on the generated script before presenting results

---

## Workflow Phases

### Phase 1: Setup

1. Read `.claude/rules/python-code-conventions.md` for project standards
2. Create Python script with proper header (title, author, purpose, inputs, outputs)
3. Load required packages at top
4. Set random seeds at top:
   ```python
   import random, numpy as np
   random.seed(42)
   np.random.seed(42)
   ```
5. Define paths using `pathlib.Path` relative to project root
6. Create output directories: `Path("output/figures").mkdir(parents=True, exist_ok=True)`

### Phase 2: Exploratory Data Analysis

Generate diagnostic outputs:
- **Summary statistics:** `.describe()`, missingness rates, dtypes
- **Distributions:** Histograms for key continuous variables
- **Relationships:** Scatter plots, correlation matrices
- **Time patterns:** If panel/time-series data, plot trends
- **Group comparisons:** If treatment/control, compare group means

Save all diagnostic figures to `output/diagnostics/`.

### Phase 3: Main Analysis

Based on the research question:
- **Regression:** `statsmodels` (`OLS`, `Logit`) or `pyfixest` for panel data
- **Machine learning:** `scikit-learn` pipelines with proper train/test splits
- **Time series:** `statsmodels`, `pmdarima`, or `prophet`
- **Multiple specifications:** Start simple, progressively add controls

### Phase 4: Publication-Ready Output

**Tables:**
- Use `stargazer` (Python port) or manual formatting for regression tables
- Export as `.tex` for LaTeX inclusion and `.csv` for inspection

**Figures:**
- Use `matplotlib` / `seaborn` / `plotly` with consistent style
- Set `dpi=300` and `bbox_inches='tight'` for quality
- Include proper axis labels (sentence case, units); no title inside figure
- For Beamer inclusion: `transparent=True`; save as `.pdf` (vector) and `.png`

### Phase 5: Review

1. Save all key objects (models, processed data) for reuse
2. Run the python-reviewer agent on the generated script:

```
Delegate to the python-reviewer agent:
"Review the script at scripts/[script_name].py"
```

3. Address any Critical or Major issues from the review.

---

## Script Structure

```python
#!/opt/homebrew/bin/python3
"""
[Descriptive Title]
Author: [from project context]
Purpose: [What this script does]
Inputs:  data/raw/[input files]
Outputs: output/figures/[figs], output/tables/[tables]
"""

# 0. Imports ------------------------------------------------------------------
import random
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Constants ----------------------------------------------------------------
random.seed(42)
np.random.seed(42)

ROOT = Path(__file__).parent.parent
DATA = ROOT / "data" / "raw"
OUTPUT = ROOT / "output"
(OUTPUT / "figures").mkdir(parents=True, exist_ok=True)
(OUTPUT / "tables").mkdir(parents=True, exist_ok=True)
(OUTPUT / "diagnostics").mkdir(parents=True, exist_ok=True)

# 2. Data Loading -------------------------------------------------------------
# [Load and inspect data]

# 3. Exploratory Analysis -----------------------------------------------------
# [Summary stats, diagnostic plots]

# 4. Main Analysis ------------------------------------------------------------
# [Models, estimation]

# 5. Tables and Figures -------------------------------------------------------
```

---

## Important

- **Reproduce, don't guess.** If the user specifies a regression, run exactly that.
- **Show your work.** Print summary statistics before jumping to modeling.
- **Check for issues.** Look for multicollinearity, outliers, class imbalance.
- **Use relative paths.** All paths via `pathlib.Path` relative to repository root.
- **No hardcoded values.** Use variables for sample restrictions, date ranges, thresholds.
