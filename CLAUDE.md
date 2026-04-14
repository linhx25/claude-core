# CLAUDE.md — Agentic Workflow Core

**Repo:** `claude-core` (generic foundation)  
**Active branch / task:** `main` — no active task

---

## What This Repo Is

This is the **generic core** for all Claude Code work. It is never used directly for tasks.
Every task gets its own branch (`research/`, `analysis/`, `dev/`) that builds on this foundation.

**Symlink pattern:** task repos symlink `.claude/` to this core, then add their own overrides.
See `templates/new-task-setup.sh` for the setup script.

---

## Non-Negotiables (Always Enforced)

1. **Plan before acting** — for any non-trivial task (>~5 steps), write a spec in `quality_reports/plans/` and get approval before touching files
2. **Run the artifact** — never claim completion without compiling, executing, or opening the output
3. **Score before committing** — nothing below 80/100 gets committed; run `/score [file]` before every commit
4. **Single source of truth** — one place defines each piece of content; no duplication
5. **LEARN tags** — when corrected, append `[LEARN:category] wrong → right` to `MEMORY.md`

---

## Operator: How Claude Behaves

Claude operates as a **contractor**, not an assistant:

- For non-trivial tasks: create requirements spec → get approval → implement → verify → review → score → deliver
- For trivial tasks (< 5 steps, unambiguous): skip spec, just do it and verify
- When uncertain: ask one clarifying question, not five
- When blocked: state what's blocked and what decision is needed, then stop
- Never claim "done" without running the artifact
- MUST ask APPROVAL if spawn >3 subagents

### Contractor Mode Modes

| Mode | When | Claude's tools |
|------|------|---------------|
| **Normal** | Implementation | All tools |
| **Delegate** (Shift+Tab) | Orchestrating agent teams | Spawn/message/task tools only — no Edit/Write/Bash |
| **Plan** | Pre-implementation | Read + analysis only |

---

## Quality Gates

| Score | Gate | Action |
|-------|------|--------|
| < 70 | BLOCK | Do not commit — fix top issue first |
| 70–79 | WARN | Ask user before committing |
| 80 | Commit threshold | Good to save |
| 90 | PR threshold | Ready for review |
| 95 | Excellence | Aspirational target |

Scoring uses the `/score [file]` command — no external script required.
Four dimensions: **Correctness** (40%) · **Completeness** (25%) · **Clarity** (20%) · **Reproducibility** (15%).
Domain overlays (research / analysis / dev) apply additional criteria on top.
`/commit` runs scoring automatically on staged files if not already scored.

Task branches may override `/score` with domain-specific extensions — see `.claude/commands/score.md`.

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/start-task` | Read CLAUDE.md, check branch, draft requirements spec |
| `/end-task` | Summarize session, update MEMORY.md, prompt "promote to main?" |
| `/score [file]` | Score any artifact against the universal rubric before committing |
| `/commit [msg]` | Score staged files → stage → commit → optional PR |
| `/context-status` | Show context usage, session health, active plan |
| `/critique [file]` | Run adversarial critic subagent on any file |
| `/learn [topic]` | Extract non-obvious session discovery into MEMORY.md |
| `/memory-prune` | Quarterly review — remove stale entries, promote principles |

*Task-specific skills live on task branches, not here.*

---

## Subagents Available (Core)

| Agent | File | When to Use |
|-------|------|-------------|
| `critic` | `.claude/agents/critic.md` | Adversarial review of any artifact |
| `researcher` | `.claude/agents/researcher.md` | Isolated literature/doc lookup (separate context) |

*Domain agents (proofreader, python-reviewer, etc.) live on task branches.*

---

## Hooks (Core — Always Active)

Hooks are configured in `.claude/settings.json`, not as shell scripts.

| Hook Event | What It Does |
|------------|-------------|
| `PreCompact` | Saves current plan snapshot before context compression |
| `PostToolUse` (Write/Edit) | Appends edit to session log |
| `SessionStart` | Loads MEMORY.md + personal.md into session context |
| `Stop` | Prompts to update MEMORY.md if session had learnings |

---

## MCP Servers

Three servers configured for this workflow. See `docs/mcp-setup-macos.md` for first-time setup.

| Server | Scope | Transport | What it enables |
|--------|-------|-----------|----------------|
| `github` | user (`~/.claude.json`) | HTTP | Repos, issues, PRs, code search |
| `brave-search` | user (`~/.claude.json`) | stdio | Web search during tasks |
| `filesystem` | project (`.mcp.json`) | stdio | File access scoped to task directory |

**One-time setup (macOS):**
```bash
# GitHub — needs a PAT in $GITHUB_PAT (add to ~/.zshrc)
claude mcp add-json github \
  '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer '"$GITHUB_PAT"'"}}' \
  --scope user

# Brave search — needs a key at https://api.search.brave.com (add BRAVE_API_KEY to ~/.zshrc)
claude mcp add brave-search --transport stdio \
  --env BRAVE_API_KEY=$BRAVE_API_KEY \
  -- npx -y @modelcontextprotocol/server-brave-search \
  --scope user
```

`filesystem` is configured per-task in `.mcp.json` — automatically scoped to the project root.

**Check status inside Claude Code:** `/mcp`

Keep total active MCP tools < 80. With Tool Search (auto-enabled on Sonnet/Opus 4), tool definitions load on demand — ~85% context reduction.

---

## Agent Teams (Experimental)

Agent teams are disabled by default. Enable in `.claude/settings.json` when needed:
```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

Use agent teams **only** when tasks are genuinely parallel with non-overlapping files.
For sequential tasks or same-file edits: single session or subagents.


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
│   ├── hooks/                   ← hook scripts referenced by settings.json
│   ├── settings.json            ← hooks config, permissions, env vars
│   └── snapshots/               ← auto-saved plan snapshots (gitignored)
├── .mcp.json                    ← MCP servers for this task
├── quality_reports/
│   ├── plans/                   ← active plan (CURRENT_PLAN.md lives here)
│   ├── specs/                   ← requirements specs (YYYY-MM-DD_description.md)
│   └── session-logs/            ← session summaries (gitignored — personal work diary)
├── templates/                   ← symlinked to claude-core/templates
└── [task-specific folders]
```

**Not in the repo (machine-local only):**
- `~/.claude/personal.md` — your preferences, background, machine config (injected at session start)

---

## Python Conventions (When Applicable)

- **Style:** PEP 8, type hints, Google-style docstrings, `black`/`ruff`
- **Reproducibility:** seed at top (`numpy.random.seed()`, `torch.manual_seed()`); relative paths only; `requirements.txt` or `pyproject.toml`
- **Visualization:** 300 DPI, consistent palette, `matplotlib`/`seaborn`
- **Notebooks:** restart-and-run-all must succeed; clear output before committing

---

## Active Task

*(Update when starting a task branch)*

| Field | Value |
|-------|-------|
| Task name | — |
| Branch | `main` |
| Started | — |
| Current status | No active task |
| Next action | — |

---

## Reminders to Claude

- Read MEMORY.md at session start — it contains hard-won learnings
- If context is > 70% full, run `/context-status` and consider compacting
- When spawning subagents: use `researcher` for lookup tasks, `critic` for review
- Snapshots in `.claude/snapshots/` are auto-generated — never manually edit them