---
name: critique
description: >
  Run the critic subagent against a task-specific attack surface loaded from
  the active rubric template. Falls back to generic adversarial review if no
  template matches. Use before committing anything important.
---

## Critique Workflow

### 1. Identify the target

If a file path was passed: use it.
If not: ask "What should I critique?" (one question).

---

### 2. Load attack surface from the matching rubric template

Use the same auto-detection as `/score`:

- Find the rubric in `templates/rubrics/{academic,coding,general}/*.md` whose
  frontmatter `applies_to` matches the file
- Load its `## Critique attack surface` section
- If no template matches: fall back to generic adversarial review (the critic
  picks the worst flaw with no specific guidance)

See `templates/rubrics/_format.md` for the rubric file format.

---

### 3. Spawn the critic subagent

Pass to the critic:

- The file content
- The "Critique attack surface" bullets from the loaded template, OR
  the instruction "no specific attack surface — perform generic adversarial review" if none
- Any context the user provided about what the artifact is meant to do

The critic agent (defined at `.claude/agents/critic.md`) runs in its own
isolated context window with restricted tools.

---

### 4. Critic returns

```
WEAKEST POINT: [one sentence]
FIX: [one concrete action]
CONFIDENCE SCORE: [0-100] — [one sentence]
```

This format is enforced by the critic agent. Do not modify it in this skill.

---

### 5. Decide next action

| Confidence | Action |
|-----------|--------|
| < 70 | Address the weakness before proceeding |
| 70–89 | User decides whether to fix or accept |
| ≥ 90 | Proceed (weakness noted for future improvement) |

---

### 6. Log

Append a one-line summary to today's session log, including which template
was used (or "generic" if none).

Format: `[HH:MM] /critique <file> [TEMPLATE: <name> | GENERIC] → confidence <N>`

---

## Why critique is task-specific

A peer reviewer attacks a literature review differently than a security
auditor attacks a service module. The active rubric's "Critique attack
surface" section tells the critic *where to look first* — which means the
critic finds the failure mode that actually matters for this artifact type,
rather than picking a generic complaint.

This is also why `/score` and `/critique` share the same template files: one
source of truth per artifact type, no drift between scoring criteria and
adversarial focus.
