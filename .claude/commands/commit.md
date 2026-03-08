---
name: commit
description: >
  Score staged files, commit locally, and optionally push to remote.
  Task branches are local-only by default — pass --push to push.
  Pass a message or Claude will generate one.
---

## Commit Workflow

### 1. Score staged files

Run `/score` on each staged file that hasn't been scored this session.
Apply the gating rules:
- BLOCK (< 70): stop, state the top issue, do not proceed
- WARN (70–79): show the score, ask "Fix first or commit anyway?"
- PASS (≥ 80): proceed

For Python files staged (`*.py`, `*.ipynb`), also run format checks:
```bash
black --check scripts/
ruff check scripts/
mypy scripts/ --ignore-missing-imports
```

For LaTeX files staged (`*.tex`):
- Confirm a `.pdf` exists and is newer than the `.tex` file

### 2. Show the diff summary and confirm

```bash
git diff --staged --stat
```

Show the user: "Committing [N files] to [branch]. OK?"
Wait for confirmation before proceeding.

### 3. Write the commit message

Format:
```
[type]: [short description]  ← max 72 chars

- [what changed and why, 1–3 bullets]
```

Types: `feat`, `fix`, `refactor`, `docs`, `analysis`, `slides`, `chore`

Use the user's message verbatim if provided. Otherwise generate from the diff.

### 4. Commit locally

```bash
git add -A
git commit -m "[message]"
```

Confirm: "Committed to [branch] (local only)."

### 5. Push — only if explicitly requested

**Default: never push task branches.**

Push only if the user passed `--push` or explicitly said "push" / "publish":

```bash
# Only run this when --push is explicitly passed
git push origin $(git branch --show-current)
```

For PRs, only if user said "PR" or "pull request" AND passed `--push`:
```bash
gh pr create --fill
# Merge only on explicit user confirmation
```

If the user asks to push without `--push`: say
"Task branches are local-only by default. Run `/commit --push` if you want
to publish this branch to remote."