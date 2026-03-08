---
paths:
  - "Slides/**/*.tex"
  - "scripts/**/*.py"
  - "scripts/notebooks/**/*.ipynb"
  - "output/**/*"
---

# Single Source of Truth: Enforcement Protocol

**The Beamer `.tex` file is the authoritative source for ALL slide content.**
**Python scripts and notebooks are the authoritative source for ALL analysis output.**
Everything else is derived.

## The SSOT Chain

```
Slides:
  Beamer .tex (SOURCE OF TRUTH for slides)
    ├── TikZ figures → PDF (derived)
    └── Bibliography_base.bib (shared)

Analysis:
  Python scripts / notebooks (SOURCE OF TRUTH for analysis)
    ├── output/figures/*.pdf, *.png (derived)
    ├── output/tables/*.tex, *.csv (derived)
    └── data/processed/*.csv, *.parquet (derived from raw)

NEVER edit derived artifacts independently.
ALWAYS propagate changes from source → derived.
```

---

## Slide Content (Beamer)

**Rule:** Edit only `.tex` files in `Slides/`. Never manually edit generated PDFs or figure files that are outputs of the Beamer compilation.

**TikZ figures:** TikZ diagrams live inside `.tex` files. If a TikZ diagram is extracted to a standalone file for compilation, the `.tex` source is still authoritative — any change goes to the source first.

---

## Analysis Output (Python)

**Rule:** `output/` is entirely derived. Never manually edit files in `output/`. If a figure or table looks wrong, fix the Python script or notebook that generates it, then re-run.

**Data pipeline:**
- `data/raw/` — read-only; never modified by scripts
- `data/processed/` — derived from raw; scripts may write here
- `output/` — derived from analysis; scripts write final figures and tables here

---

## Cross-Source Consistency

When analysis results appear in slides:
- The number in the slide must match the number produced by the script
- If a script is updated and produces new numbers, update the `.tex` file to match
- Document the script path in a comment near the number in the `.tex` file:
  `% Source: scripts/analysis.py, Table 2`
