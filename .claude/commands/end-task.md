---
name: end-task
description: >
  Close out a task session. Summarizes what was done, updates MEMORY.md with
  learnings, and prompts whether anything should be promoted to main.
  Use this at the end of every substantial work session.
---

## End Task Workflow

1. **Summarize the session**
   - What was completed (done ✓)
   - What is in progress (in progress →)
   - What was deferred or blocked (blocked ✗)
   - Write this to `quality_reports/session-logs/session_YYYY-MM-DD.md` using `templates/session-log.md`

2. **Extract learnings**
   - Review the session: was anything non-obvious discovered?
   - If yes: append to `MEMORY.md` as `[LEARN:category] wrong → right`
   - If no new learnings: write "No new learnings this session"

3. **Promotion check**
   - Review any new agents, skills, rules, or hooks added on this branch
   - Ask: "Any of these generic enough to promote to `main`?"
   - List candidates with a yes/no recommendation

4. **Quality status**
   - Report the last quality score for deliverables touched this session
   - Flag anything below 80 that needs follow-up

5. **Update CLAUDE.md** — update "Active Task" table: status, next action

6. **Confirm closed**: "Session closed. Next action: [next action]."
