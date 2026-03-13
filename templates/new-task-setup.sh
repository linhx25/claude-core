#!/usr/bin/env bash
# new-task-setup.sh
# Sets up a new task branch using the claude-core symlink pattern.
#
# Usage:
#   bash new-task-setup.sh <branch-type> <task-name> [project-root]
#
# Branch types: research | analysis | dev | exploration
#
# Example:
#   bash new-task-setup.sh research ml-paper-2026 ~/projects/ml-paper
#   bash new-task-setup.sh analysis housing-data ~/projects/housing
#   bash new-task-setup.sh dev api-server ~/projects/api

set -euo pipefail

BRANCH_TYPE="${1:-}"
TASK_NAME="${2:-}"
PROJECT_ROOT="${3:-$(pwd)}"
CORE_REPO="${CLAUDE_PROJECT_DIR:-$(pwd)}/claude-core"

# ── Validation ────────────────────────────────────────────────────────────────

if [ -z "$BRANCH_TYPE" ] || [ -z "$TASK_NAME" ]; then
  echo "Usage: $0 <branch-type> <task-name> [project-root]"
  echo "Branch types: research | analysis | dev | exploration"
  exit 1
fi

if [ ! -d "$CORE_REPO" ]; then
  echo "Error: claude-core not found at $CORE_REPO"
  echo "Clone it first: git clone <your-core-repo-url> ~/.claude-core"
  exit 1
fi

BRANCH_NAME="${BRANCH_TYPE}/${TASK_NAME}"

echo "Setting up task: $BRANCH_NAME"
echo "Project root:    $PROJECT_ROOT"
echo "Core repo:       $CORE_REPO"
echo ""

# ── Project directory ─────────────────────────────────────────────────────────

mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT"

if [ ! -d .git ]; then
  git init
  echo "Initialized git repo"
fi

# ── Create branch ─────────────────────────────────────────────────────────────

git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
echo "On branch: $BRANCH_NAME (local only — will not push unless you run /commit --push)"
echo ""

# ── Wire .claude/ ─────────────────────────────────────────────────────────────

mkdir -p .claude/snapshots

# commands/ — symlink each core file so Claude Code discovers them.
# Task-specific files in the same folder shadow core ones by same filename.
mkdir -p .claude/commands
echo "Linking core commands..."
for cmd in "$CORE_REPO/.claude/commands/"*.md; do
  fname=$(basename "$cmd")
  if [ ! -e ".claude/commands/$fname" ]; then
    ln -s "$cmd" ".claude/commands/$fname"
    echo "  + $fname"
  else
    echo "  ~ $fname (task override kept)"
  fi
done

# agents/ — same pattern
mkdir -p .claude/agents
echo "Linking core agents..."
for agent in "$CORE_REPO/.claude/agents/"*.md; do
  fname=$(basename "$agent")
  if [ ! -e ".claude/agents/$fname" ]; then
    ln -s "$agent" ".claude/agents/$fname"
    echo "  + $fname"
  else
    echo "  ~ $fname (task override kept)"
  fi
done

# hooks/ — symlink the whole directory.
# settings.json already uses .claude/hooks/ paths matching the core repo — no rewriting needed.
if [ ! -e ".claude/hooks" ]; then
  ln -s "$CORE_REPO/.claude/hooks" .claude/hooks
  echo "Linked: .claude/hooks → $CORE_REPO/.claude/hooks"
fi

# settings.json — copy (not symlink) so task can customize permissions/env
if [ ! -f ".claude/settings.json" ]; then
  cp "$CORE_REPO/.claude/settings.json" .claude/settings.json
  echo "Copied: .claude/settings.json"
fi

echo ""

# ── Copy CLAUDE.md and MEMORY.md ──────────────────────────────────────────────

if [ ! -f CLAUDE.md ]; then
  cp "$CORE_REPO/CLAUDE.md" CLAUDE.md
  sed -i.bak "s|Active branch / task:.*|Active branch / task: \`${BRANCH_NAME}\` — [fill in task description]|" CLAUDE.md
  rm -f CLAUDE.md.bak
  echo "Copied: CLAUDE.md (fill in Active Task table before running /start-task)"
fi

if [ ! -f MEMORY.md ]; then
  cp "$CORE_REPO/MEMORY.md" MEMORY.md
  echo "Copied: MEMORY.md"
fi

# ── Project structure ─────────────────────────────────────────────────────────

mkdir -p quality_reports/{plans,session-logs}

if [ ! -e templates ]; then
  ln -s "$CORE_REPO/templates" templates
  echo "Linked: templates → $CORE_REPO/templates"
fi

# Domain-specific folders
case "$BRANCH_TYPE" in
  research)
    mkdir -p slides related_work output/figures preambles
    echo "Created: research structure"
    ;;
  analysis)
    mkdir -p data/{raw,processed} output/{figures,tables,reports} scripts/notebooks
    echo "Created: analysis structure"
    ;;
  dev)
    mkdir -p src tests docs scripts
    echo "Created: dev structure"
    ;;
  exploration)
    mkdir -p explorations output
    echo "Created: exploration structure"
    ;;
esac

# ── .mcp.json ─────────────────────────────────────────────────────────────────

if [ ! -f .mcp.json ]; then
  EXPANDED_ROOT=$(cd "$PROJECT_ROOT" && pwd)
  cat > .mcp.json << EOF
{
  "_doc": "Project-scoped MCP. GitHub + web search are user-scoped in ~/.claude.json (see docs/mcp-setup-macos.md).",
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${EXPANDED_ROOT}"]
    }
  }
}
EOF
  echo "Created: .mcp.json (filesystem scoped to $EXPANDED_ROOT)"
fi

# ── .gitignore ────────────────────────────────────────────────────────────────

if [ ! -f .gitignore ]; then
  cat > .gitignore << 'EOF'
# Build artifacts
*.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg

# Python
__pycache__/ *.pyc .ipynb_checkpoints/ .mypy_cache/ .ruff_cache/

# Data
data/raw/

# Secrets
.env .env.* secrets/

# macOS
.DS_Store

# Claude snapshots
.claude/snapshots/

# Session logs
quality_reports/session-logs/
EOF
  echo "Created: .gitignore"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "✓ Task branch ready: $BRANCH_NAME"
echo ""
echo "This branch is LOCAL ONLY. Never pushes unless you run: /commit --push"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_ROOT"
echo "  2. Edit CLAUDE.md — fill in task name and Active Task table"
echo "  3. claude"
echo "  4. /start-task"
echo ""
echo "To add task-specific commands:  .claude/commands/your-command.md"
echo "To add task-specific agents:    .claude/agents/your-agent.md"