# claude-core

Generic Claude Code foundation. Never used directly for tasks — always branched or symlinked.

## What's Here

```
claude-core/
├── CLAUDE.md                    ← Project memory (update per task)
├── MEMORY.md                    ← Accumulated learnings (append-only)
├── .mcp.json                    ← Filesystem server (project-scoped); GitHub/search are user-scoped
├── docs/
│   └── mcp-setup-macos.md       ← First-time MCP setup guide (macOS)
├── .claude/
│   ├── settings.json            ← Hooks config, permissions, env vars
│   ├── agents/
│   │   ├── critic.md            ← Adversarial reviewer (any artifact)
│   │   └── researcher.md        ← Isolated lookup agent
│   ├── commands/                ← Slash skills
│   │   ├── start-task.md        ← /start-task
│   │   ├── end-task.md          ← /end-task
│   │   ├── score.md             ← /score  (universal rubric — no external script)
│   │   ├── commit.md            ← /commit
│   │   ├── context-status.md    ← /context-status
│   │   ├── critique.md          ← /critique
│   │   ├── learn.md             ← /learn
│   │   ├── memory-prune.md      ← /memory-prune
│   │   └── devils-advocate.md   ← /devils-advocate
│   └── hooks/
│       ├── pre-compact.sh       ← Saves plan snapshot before compression
│       ├── session-start.sh     ← Injects MEMORY.md at session start
│       ├── log-edit.sh          ← Logs file edits during session
│       └── session-stop.sh      ← Reminds to update MEMORY.md at end
└── templates/
    ├── requirements-spec.md     ← MUST/SHOULD/MAY plan template
    ├── session-log.md           ← Session summary template
    └── new-task-setup.sh        ← Script to bootstrap a new task branch
```

## Setup

```bash
# 1. Clone as your core
git clone <this-repo-url> ./claude-core

# 2. Start a new task (creates folders, branch, copies CLAUDE.md)
bash ./claude-core/templates/new-task-setup.sh research my-paper ./projects/my-paper

# 3. Update CLAUDE.md manually: fill in task name, description, Active Task table

# 4. start Claude Code
cd ./projects/my-paper
claude

# 5. Claude reads CLAUDE.md, drafts the spec
/start-task
```

## Architecture: Six Layers

| Layer | Where | Role |
|-------|-------|------|
| **CLAUDE.md** | repo root | Memory — project context, non-negotiables, active task |
| **Rules** | CLAUDE.md + `settings.json` | Standing constraints on behavior |
| **Hooks** | `.claude/hooks/` + `settings.json` | Automatic middleware (lifecycle events) |
| **Skills** | `.claude/commands/` | Callable `/slash-commands` |
| **Agents** | `.claude/agents/` | Specialized subagents spawned for review/research |
| **MCP** | user `~/.claude.json` + project `.mcp.json` | External tool connections |

## Key Design Decisions

**Why symlinks instead of copies?**  
Copies drift. When you improve a core hook or skill, copies don't benefit. Symlinks to `core-commands`, `core-hooks`, and `core-agents` ensure all tasks get updates automatically. Task-level additions live in the task's own `.claude/` directories.

**Why is `settings.json` copied, not symlinked?**  
Tasks may need different permissions or to enable agent teams. Copying lets each task customize without affecting core.

**Why are agent teams disabled by default?**  
They cost ~3–7× tokens. Enable only when tasks are genuinely parallel with non-overlapping file boundaries. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` in the task's `settings.json`.

## Promoting Work Back to Core

After finishing a task, check what you built:

```bash
git diff main --name-only -- .claude/
```

For each new agent/skill/hook: ask "is this domain-specific or generic?"
Generic → cherry-pick to `main`. Domain-specific → leave on the branch.

```bash
git checkout main
git checkout task/my-branch -- .claude/commands/my-new-skill.md
git commit -m "chore: promote /my-new-skill to core"
```