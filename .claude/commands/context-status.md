---
name: context-status
description: >
  Shows current session health: context window usage, active branch, plan
  status, most recent quality scores, and any pending LEARN entries.
  Run this proactively when sessions feel long or complex.
---

## Context Status Report

Report the following in a compact table:

### Session Health

| Item | Status |
|------|--------|
| Active branch | `git branch --show-current` |
| Context usage | Estimate: [low / medium / high / critical] |
| Active plan | Check if `quality_reports/plans/CURRENT_PLAN.md` exists |
| Session log | Check `quality_reports/session-logs/session_YYYY-MM-DD.md` |
| Latest snapshot | Check `.claude/snapshots/` — most recent plan_*.md |

### Recommendation

- If context is **high** (> 70% estimated): suggest `/compact` or wrapping up
- If context is **critical**: strongly recommend compacting now (pre-compact hook will save plan)
- If no active plan and task > 30 min in: suggest creating one

### Quick Scores (last known)

List the last quality score for any files scored this session.
If none: "No files scored this session."
