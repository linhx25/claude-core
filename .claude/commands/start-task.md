---
name: start-task
description: >
  Begin a new task. Reads CLAUDE.md and MEMORY.md, checks the current branch,
  asks for a task description if not provided, and drafts a requirements spec
  in quality_reports/plans/. Use this at the start of every session on a task branch.
---

## Start Task Workflow

1. **Read context**
   - Read `CLAUDE.md` — note non-negotiables, active task field, branch
   - Read `MEMORY.md` — note any relevant LEARN entries for this domain
   - Read `personal.md` 
   - Run `git branch --show-current` to confirm the active branch

2. **Clarify the task**
   - If the user provided a task description: use it
   - If not: ask "What are we working on today?" (one question only)

3. **For non-trivial tasks (> ~5 steps): draft a requirements spec**
   - Create `quality_reports/plans/CURRENT_PLAN.md` using the template at `templates/requirements-spec.md`
   - Fill in: task name, MUST/SHOULD/MAY priorities, clarity status (CLEAR / ASSUMED / BLOCKED)
   - Present the spec to the user for approval before proceeding

4. **For trivial tasks**: confirm understanding in one sentence, then proceed

5. **Update CLAUDE.md** — fill in the "Active Task" table at the bottom

6. **Confirm ready**: "Plan approved. Starting [task name]."
