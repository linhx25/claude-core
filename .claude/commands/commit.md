---
name: commit
description: >
  Stage, quality-check, commit, and optionally create a PR. Runs pre-commit
  checks appropriate to the file types being committed. Blocks if quality
  score < 80. Pass a message or Claude will generate one.
---

## Commit Workflow

### 1. Pre-commit quality check (auto-detect by file type)

For Python files staged (`*.py`, `*.ipynb`):
```bash
black --check scripts/
ruff check scripts/
mypy scripts/ --ignore-missing-imports
```

For LaTeX files staged (`*.tex`):
- Confirm latest compilation succeeded (check for `.pdf` output newer than `.tex`)

For any file: run `python scripts/quality_score.py [file]` if it exists.
Block if score < 80. Fix issues and re-score before proceeding.

### 2. Confirm what's being committed

```bash
git diff --staged --stat
```

Show the user the diff summary and confirm: "Committing [N files]. OK?"

### 3. Write the commit message

Format:
```
[type]: [short description]  ← max 72 chars

- [what changed and why, 1–3 bullets]
```

Types: `feat`, `fix`, `refactor`, `docs`, `analysis`, `slides`, `chore`

If the user passed a message: use it verbatim.
If not: generate one from the diff.

### 4. Commit

```bash
git add -A
git commit -m "[generated or user message]"
```

### 5. Optional: PR and merge

If user said "PR", "merge", or "push":
```bash
git push origin $(git branch --show-current)
gh pr create --fill
# Only merge if user explicitly confirms
```
