---
name: learn
description: >
  Extracts a non-obvious discovery from the current session and appends it to
  MEMORY.md in the [LEARN:category] format. Use when something surprising,
  tricky, or corrected happened that future sessions should know.
---

## Learn Workflow

1. **Identify the learning**
   - If the user described what to learn: use their description
   - If invoked without input: ask "What should I remember from this?"

2. **Classify the tier — ask before appending**

   Present these options and wait for the user's choice:
   - **PATTERN** — reusable cross-project learning, corrected mistake → append to `MEMORY.md`
   - **DOMAIN** — tool/language-specific gotcha (LaTeX, Python, hooks, etc.) → append to `MEMORY.md`
   - **HABIT** — personal or machine-specific preference → append to `personal.md` instead
   - **PRINCIPLE** — stable design philosophy, non-negotiable → suggest adding directly to `CLAUDE.md` under the appropriate section

   If it's clearly a PRINCIPLE, say: "This sounds like a principle rather than a pattern — it might belong in CLAUDE.md instead of MEMORY.md. Should I add it there?"

   If it's clearly a HABIT, say: "This sounds personal/machine-specific — it belongs in personal.md (gitignored) rather than MEMORY.md."

3. **Format the entry**

For MEMORY.md (PATTERN or DOMAIN):
```
## [YYYY-MM-DD] — [brief title]
[LEARN:category] [what was wrong or assumed] → [what is actually correct]
Context: [one sentence on when this matters]
```

Categories: `workflow`, `documentation`, `design`, `files`, `memory`, `skills`, `latex`, `python`, `mcp`, `hooks`, `agents`, `general`

For personal.md (HABIT): free-form, no strict format required.

For CLAUDE.md (PRINCIPLE): add under the most relevant section heading.

4. **Append to the correct file** — never overwrite, always append to the section matching the entry's domain (e.g., under `## Workflow Patterns` for a workflow entry).

5. **Confirm**: "Saved to [file]: [LEARN:category] [summary]"
