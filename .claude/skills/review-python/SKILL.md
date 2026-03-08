---
name: review-python
description: Run the Python code review protocol on Python scripts or Jupyter notebooks. Checks code quality, reproducibility, logic correctness, and output standards. Produces a report without editing files.
argument-hint: "[path to .py or .ipynb file]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Task"]
---

# Python Code Review

Run the python-reviewer agent on a Python script or Jupyter notebook.

**Input:** `$ARGUMENTS` — path to a `.py` script or `.ipynb` notebook.

---

## Steps

### 1. Identify the File

Parse `$ARGUMENTS` for the file path. Resolve relative to project root.
- Scripts live in `scripts/`
- Notebooks live in `notebooks/`

### 2. Read Project Conventions

Read `.claude/rules/python-code-conventions.md` to load current project standards.

### 3. Run the Review Agent

Delegate to the `python-reviewer` agent:

```
Review the file at [resolved path].
Apply the python-reviewer protocol: check code style, reproducibility,
logic correctness, and output quality.
Save the report to quality_reports/[FILENAME_WITHOUT_EXT]_python_review.md
```

### 4. Run Syntax Check

```bash
python3 -m py_compile [filepath]
```

Report pass/fail. If fail, this is a CRITICAL issue.

### 5. Present Summary

After the agent completes, present:
- Overall assessment (CLEAN / MINOR / MAJOR / CRITICAL)
- Top 3 issues by severity
- Quality score estimate
- Path to the saved report

---

## Example Usage

```
/review-python scripts/analysis.py
/review-python notebooks/eda.ipynb
```
