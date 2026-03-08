---
name: memory-prune
description: >
  Quarterly review of MEMORY.md and personal.md. Removes stale entries,
  consolidates redundant ones, re-tiers misclassified entries, and promotes
  strong stable patterns to CLAUDE.md principles. Run every ~3 months or
  when MEMORY.md exceeds ~50 entries.
---

## Memory Prune Workflow

This is a deliberate review, not an automated cleanup. Take your time.

---

### Step 1: Count and assess

Read MEMORY.md and personal.md in full. Report:
- Total entry count per tier (PATTERN / DOMAIN / HABIT)
- Date range of entries (oldest → newest)
- Any obvious clusters of related entries

If total entries < 20 and file is < 6 months old: tell the user pruning isn't
needed yet and stop.

---

### Step 2: Evaluate each entry against four criteria

For every `[LEARN:*]` entry, silently evaluate:

| Criterion | Question | Action if failing |
|-----------|----------|-------------------|
| **Still true?** | Has this been superseded or was it context-specific? | Mark STALE |
| **Actionable?** | Would Claude actually behave differently knowing this? | Mark VAGUE |
| **Non-redundant?** | Is the same insight already expressed elsewhere? | Mark DUPLICATE |
| **Right tier?** | Is a PRINCIPLE hiding in PATTERN? A HABIT in DOMAIN? | Flag for re-tier |

---

### Step 3: Present findings before touching anything

Show a structured report:

```
MEMORY PRUNE REPORT — [date]
Total entries: N

STALE (no longer true or too context-specific):
- [entry summary] — reason

VAGUE (not actionable enough to change behavior):
- [entry summary] — reason

DUPLICATE (same insight expressed elsewhere):
- [entry A] duplicates [entry B] — keep which one?

RE-TIER candidates:
- [entry] currently PATTERN → suggest PRINCIPLE (move to CLAUDE.md)
- [entry] currently PATTERN → suggest HABIT (move to personal.md)

PROMOTIONS to CLAUDE.md (strong, stable, universal):
- [entry] — reason it's earned principle status

CONSOLIDATIONS (merge N entries into 1):
- [entries] → [proposed merged entry]
```

Ask: "Approve this plan? (yes / modify / cancel)"

---

### Step 4: Execute only on approval

Apply changes in this order:
1. Delete STALE and confirmed DUPLICATE entries
2. Rewrite VAGUE entries with sharper language (or delete if unrescuable)
3. Move HABIT entries to personal.md
4. Consolidate clusters into single entries
5. Move PRINCIPLE entries to CLAUDE.md under the appropriate section
6. Add a prune log entry at the top of MEMORY.md:

```markdown
<!-- PRUNED [YYYY-MM-DD]: N entries removed, M consolidated, P promoted to CLAUDE.md -->
```

---

### Step 5: After pruning, assess health

Report the final state:
- Entries before → after
- Promoted to CLAUDE.md: N
- Moved to personal.md: N
- Estimated next prune: [date ~3 months out]

---

## What makes a PRINCIPLE vs PATTERN vs HABIT

**PRINCIPLE** — universal, stable, design-level. True regardless of task or machine.
> "Framework-oriented > prescriptive rules" — goes in CLAUDE.md

**PATTERN** — reusable workflow learning. True across projects but arose from experience.
> "Spec-then-plan reduces rework 30-50% on tasks >1 hour" — stays in MEMORY.md

**HABIT** — personal or machine-specific. True for you but not for a collaborator cloning this repo.
> "I prefer running black before committing, not as a hook" — goes in personal.md
