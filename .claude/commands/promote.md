---
name: promote
description: >
  Promote generic work from a task branch back to main. Diffs .claude/ and
  templates/ against main, classifies each change as generic or domain-specific,
  cherry-picks the generic ones, and updates README + CLAUDE.md inventory.
  Run at the end of a task before closing the branch.
---

## Promote Workflow

### 1. Confirm we're on a task branch

```bash
git branch --show-current
```

If the result is `main`: stop. Promotion only runs from task branches.

### 2. Diff against main

```bash
git diff main --name-status -- .claude/ templates/
```

For each changed file, note status:
- **A** — added (new agent / skill / hook / template)
- **M** — modified (extension or fix to a core file)
- **D** — deleted (removed something on the branch)

Skip auto-generated and gitignored paths: `.claude/snapshots/`,
`quality_reports/session-logs/`, `*.local.*`.

### 3. Classify each change

For each file, ask three questions:

- Is the *purpose* tied to this task's domain? (e.g. `score-latex.md` → yes, domain)
- Would a user on a different branch type (research / analysis / dev) benefit? (yes → generic)
- Does it reference task-specific paths, libraries, or vocabulary? (yes → domain)

If 2-of-3 lean generic → propose for promotion.
If 2-of-3 lean domain-specific → leave on branch.
If unclear → ask the user.

### 4. Present the candidate table

```
PROMOTE CANDIDATES — [branch] → main

Generic (suggest promote):
  A  .claude/commands/check-deps.md   — runs language-agnostic dep check
  M  .claude/commands/score.md        — adds untested-cap rule

Domain-specific (leave on branch):
  A  .claude/agents/latex-proofreader.md — LaTeX-only
  A  .claude/commands/score-bib.md       — bibliography-specific
```

Ask: "Promote the generic ones? (yes / pick subset / cancel)"

### 5. Execute on approval

Stash any uncommitted work first:
```bash
git stash push -u -m "promote-temp"
```

Switch to main and cherry-pick each approved file:
```bash
git checkout main
git checkout <task-branch> -- <file1> <file2> ...
```

Update inventory in the same commit:
- `README.md` "What's Here" tree — add new agents / skills / hooks
- `CLAUDE.md` Skills Quick Reference table — add new slash-commands
- `CLAUDE.md` Subagents Available table — add new agents

Run `/score` on `README.md` and `CLAUDE.md` to confirm the inventory updates
pass the rubric (≥80).

### 6. Commit

```bash
git commit -m "chore: promote [N] generic items from <task-branch> to core

- Promoted: [list of files]
- Updated README + CLAUDE.md inventory"
```

### 7. Return to task branch

```bash
git checkout <task-branch>
git stash pop  # only if stashed in step 5
```

### 8. Reminder

Do NOT push automatically. Promotion to remote main is a separate step
requiring explicit user confirmation:

```bash
git push origin main  # only when user explicitly says push / publish
```
