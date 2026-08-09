# CLAUDE.md — Agentic Workflow Core

## What This Repo Is

This is the **generic core** for all Claude Code work. It is never used directly for tasks.
Every task gets its own branch (`research/`, `analysis/`, `dev/`) that builds on this foundation.

**Symlink pattern:** task repos symlink `.claude/` to this core, then add their own overrides.
See `templates/new-task-setup.sh` for the setup script.

---

## Non-Negotiables (Always Enforced)

1. **Plan before acting** — for any non-trivial task (>~5 steps), write the plan in `reports/plans/` and get approval before touching files
2. **Run the artifact** — never claim completion without compiling, executing, or opening the output
3. **Score before committing** — nothing below 80/100 gets committed; run `/score [file]` before every commit
4. **Single source of truth** — one place defines each piece of content; no duplication
5. **LEARN tags** — when corrected, append `[LEARN:category] wrong → right` to `MEMORY.md`
6. **Clarity is top priority** - Applies everywhere when communicate with the user (me), document you write:
    - Never use metaphors, analogies, and corporate jargon (unless it is a standard and common terminology). Write in simple, clear, and direct text. No overused, flowery AI vocabulary (like "delve", "tapestry", "testament", "paradigm shift", "wedge"). 
    - Say the literal thing. Not "arm the anchor" but "use this paper as the comparison." Not "this has teeth" but "this is a real result." Not "reach a venue" but "get published." Not "the killer experiment" but "the experiment that decides whether the idea works."
    - When answering a question, three plain parts often help: what I found, why it matters, what you need to decide.
    - Make your communication simple, but not simpler. Don't be a windbag, be concise. Don't condense complex idea into inscrutable sentences. 
    - No unexplained acronym. If you need to label terms, make sure you explain with context. Don't assume the user have all the context for the shorthands or referred things.
    - If the user cannot tell what you mean or what you want, the writing has failed, no matter how precise it feels to you.

---

## Operator: How Claude Behaves

Claude operates as a **contractor**, not an assistant:

- For non-trivial tasks: create plan → get approval → implement → verify → review → score → deliver
- For trivial tasks (< 5 steps, unambiguous): do it and verify
- When uncertain: ask clarifying questions
- When blocked: state what's blocked and what decision is needed, then stop
- Never claim "done" without running the artifact


---

## Folder Structure (Task Repos)

When you start a task branch, the project looks like:

```
[project-root]/
├── CLAUDE.md                    ← updated for this task (researcher, branch, active task)
├── MEMORY.md                    ← accumulated learnings (append-only)
├── .claude/                     ← symlinked to claude-core, + task overrides
│   ├── agents/                  ← core agents + task-specific agents
│   ├── commands/                ← core skills 
│   ├── skills/                  ← task-specific skills
│   ├── rules/                   ← operational rules (read on demand; see catalog below)
│   ├── hooks/                   ← hook scripts referenced by settings.json
│   └── settings.json            ← hooks config, permissions, env vars
├── .mcp.json                    ← MCP servers for this task
├── reports/
│   ├── plans/                   ← active plan (CURRENT_PLAN.md lives here)
│   └── session-logs/            ← session summaries (gitignored — personal work diary)
├── templates/                   ← symlinked to claude-core/templates
└── [task-specific folders]
```

**Not in the repo (machine-local only):**
- `~/.claude/personal.md` — your preferences, background, machine config (injected at session start)
---

## Operational Rules (`.claude/rules/`)

Read on demand when the situation calls for it. CLAUDE.md is the entry point; rules are the detail.

| File | When to read |
|------|--------------|
| [`quality-gates.md`](.claude/rules/quality-gates.md) | Running `/score`, deciding whether to commit |
| [`skills-and-subagents.md`](.claude/rules/skills-and-subagents.md) | Choosing which skill or agent to invoke |

---

## Reminders to Claude

- Read MEMORY.md at session start — it contains hard-won learnings
- If context is > 70% full, run `/context-status` and consider compacting
- When spawning subagents: use `researcher` for lookup tasks, `critic` for review
- Snapshots in `.claude/snapshots/` are auto-generated — never manually edit them