# Skills, Subagents, Hooks, MCP

The full catalog of agentic tooling available in this repo.

## Skills

Two locations:
- `.claude/commands/` — legacy flat-file convention (`/start-task`, `/score`, etc.)
- `.claude/skills/<name>/SKILL.md` — folder-per-skill convention (used by all ideation skills)

Both are discovered by Claude Code.

### Core workflow (`.claude/commands/`)

| Command | What It Does |
|---------|--------------|
| `/start-task` | Read CLAUDE.md, check branch, draft requirements spec |
| `/end-task` | Summarize session, update MEMORY.md, prompt "promote to main?" |
| `/score [file]` | Score artifact against rubric (see `quality-gates.md`) |
| `/commit [msg]` | Score staged files → stage → commit → optional PR |
| `/context-status` | Show context usage, session health, active plan |
| `/critique [file]` | Run adversarial critic subagent on any file |
| `/learn [topic]` | Extract non-obvious session discovery into MEMORY.md |
| `/memory-prune` | Quarterly review — remove stale entries, promote principles |

## Subagents

| Agent | File | Tools | When to Use |
|-------|------|-------|-------------|
| `critic` | `.claude/agents/critic.md` (symlinked) | Read, Glob, Grep | Adversarial review of any artifact (proposals especially) |
| `researcher` | `.claude/agents/researcher.md` (symlinked) | Read, Glob, Grep, WebFetch, WebSearch | Generic literature / doc lookup in isolated context |

Project-specific agents (e.g., a workforce-reallocation literature reviewer) live under the project folder when needed, not at the repo root.

## Hooks (Always Active)

Configured in `.claude/settings.json`, scripts symlinked from claude-core.

| Hook Event | What It Does |
|------------|--------------|
| `PreCompact` | Saves current plan snapshot before context compression |
| `PostToolUse` (Write/Edit) | Appends edit to session log |
| `SessionStart` | Loads MEMORY.md + personal.md into context |
| `Stop` | Prompts to update MEMORY.md if session had learnings |

## MCP Servers

| Server | Scope | What It Enables |
|--------|-------|-----------------|
| `github` | user | Repos, issues, PRs, code search |
| `brave-search` | user | Web search for literature, data sources |
| `filesystem` | project (`.mcp.json`) | File access scoped to `research/` |

Setup: `docs/mcp-setup-macos.md` (created on first MCP need). Keep total active MCP tools < 80.

### TODO if this hasn't been done: set up Scrapling MCP via https://scrapling.readthedocs.io/en/latest/ai/mcp-server.html for the first-time setup.
