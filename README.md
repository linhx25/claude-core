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
│   │   ├── start-task.md            ← /start-task
│   │   ├── end-task.md              ← /end-task
│   │   ├── score.md                 ← /score (loads task-specific rubric from templates/rubrics/)
│   │   ├── commit.md                ← /commit
│   │   ├── context-status.md        ← /context-status
│   │   ├── critique.md              ← /critique (task-specific attack surface from rubric template)
│   │   ├── learn.md                 ← /learn
│   │   ├── memory-prune.md          ← /memory-prune
│   │   ├── promote.md               ← /promote (cherry-pick generic work to main)
│   │   ├── framework-doctor.md      ← /framework-doctor (audit core for drift)
│   │   └── build-rubric-template.md ← /build-rubric-template (4-phase interview to build new rubrics)
│   ├── hooks/
│   │   ├── pre-compact.sh       ← Saves plan snapshot before compression
│   │   ├── session-start.sh     ← Injects MEMORY.md at session start
│   │   ├── log-edit.sh          ← Logs file edits during session
│   │   └── session-stop.sh      ← Reminds to update MEMORY.md at end
│   └── skills/
│       └── skill-creator/       ← Anthropic's official skill-creation toolkit
│                                  (use to author new commands or subagents)
└── templates/
    ├── requirements-spec.md     ← MUST/SHOULD/MAY plan template
    ├── session-log.md           ← Session summary template
    ├── new-task-setup.sh        ← Script to bootstrap a new task branch
    └── rubrics/                 ← Task-specific rubric library
        ├── _format.md           ← Rubric file format spec
        ├── academic/            ← Hand-tuned rubrics for academic artifacts
        ├── coding/              ← Hand-tuned rubrics for code
        └── general/             ← Auto-built rubrics for other artifact types
```

## Setup

```bash
# 1. Clone as your core
git clone <this-repo-url> ./claude-core

# 2. Start a new task (creates folders, branch, copies CLAUDE.md)
bash ./claude-core/templates/new-task-setup.sh research my-paper <your-directory>

# 3. Update CLAUDE.md manually: fill in task name, description, Active Task table

# 4. start Claude Code
cd <your-directory>
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

## Tips

**Daily Reset Usage Limit**  
Set up a scheduled task from the Claude app by sending you a "hello" message at specific time to reset the hour usage limit. For example, if your work starts at 8AM, schedule the hello message on 5~6 AM to start the session limit countdown earlier.

**/clear**  
Use /clear when you switch to a new topic or new task, it will clean up the long context



## Promoting Work Back to Core

After finishing a task, generic skills/agents/hooks built on a task branch can be promoted back to `main` so future tasks inherit them. Domain-specific work stays on the branch.

### Use the `/promote` skill (recommended)

Run from the task branch:

```bash
/promote
```

The skill walks through these steps automatically:

1. **Confirms branch** — refuses to run from `main`.
2. **Diffs against main** — `git diff main --name-status -- .claude/ templates/`, skipping auto-generated paths (`.claude/snapshots/`, `reports/session-logs/`, `*.local.*`).
3. **Classifies each change** as **generic** or **domain-specific** using three questions:
   - Is the purpose tied to this task's domain?
   - Would a user on a different branch type (research / analysis / dev) benefit?
   - Does it reference task-specific paths, libraries, or vocabulary?
4. **Presents a candidate table** of generic-vs-domain-specific changes and asks for approval (yes / pick subset / cancel).
5. **Cherry-picks approved files** onto `main`:
   ```bash
   git stash push -u -m "promote-temp"
   git checkout main
   git checkout <task-branch> -- <approved files>
   ```
6. **Updates inventory** in the same commit:
   - `README.md` "What's Here" tree — new agents / skills / hooks
   - `CLAUDE.md` "Skills Quick Reference" — new slash commands
   - `CLAUDE.md` "Subagents Available" — new agents
7. **Scores the inventory updates** — runs `/score` on `README.md` and `CLAUDE.md` (must pass ≥ 80).
8. **Commits** with a message like `chore: promote [N] generic items from <task-branch> to core`.
9. **Returns to the task branch** and pops the stash if one was created.

`/promote` does **not** push to remote. Pushing `main` is a separate, explicit step:

```bash
git push origin main   # only when you explicitly want to publish
```

### Manual fallback

If you prefer to promote a single file without the full workflow:

```bash
git diff main --name-only -- .claude/                          # see what changed
git checkout main
git checkout <task-branch> -- .claude/commands/my-new-skill.md  # cherry-pick the file
# Then update README.md + CLAUDE.md inventory by hand before committing
git commit -m "chore: promote /my-new-skill to core"
```

Remember to update both `README.md` and `CLAUDE.md` whenever you add a skill/agent/hook — documentation drift breaks user trust.