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
CORE_REPO="$HOME/.claude-core"

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

# Init git if needed
if [ ! -d .git ]; then
  git init
  echo "Initialized git repo"
fi

# ── Create branch ─────────────────────────────────────────────────────────────

git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
echo "On branch: $BRANCH_NAME"

# ── Symlink .claude/ to core ──────────────────────────────────────────────────

# Strategy: symlink the core's .claude/ subdirectories, keep project-level
# settings.json and agents/ separate so task-specific additions don't pollute core.

mkdir -p .claude/{agents,commands,hooks,snapshots}

# Symlink core commands and hooks (read-only from core)
if [ ! -L ".claude/core-commands" ]; then
  ln -s "$CORE_REPO/.claude/commands" .claude/core-commands
  echo "Linked: .claude/core-commands → $CORE_REPO/.claude/commands"
fi

if [ ! -L ".claude/core-hooks" ]; then
  ln -s "$CORE_REPO/.claude/hooks" .claude/core-hooks
  echo "Linked: .claude/core-hooks → $CORE_REPO/.claude/hooks"
fi

if [ ! -L ".claude/core-agents" ]; then
  ln -s "$CORE_REPO/.claude/agents" .claude/core-agents
  echo "Linked: .claude/core-agents → $CORE_REPO/.claude/agents"
fi

# Copy (not symlink) settings.json so task can customize
if [ ! -f ".claude/settings.json" ]; then
  cp "$CORE_REPO/.claude/settings.json" .claude/settings.json
  echo "Copied: .claude/settings.json (task-editable)"
fi

# ── Copy CLAUDE.md template ───────────────────────────────────────────────────

if [ ! -f CLAUDE.md ]; then
  cp "$CORE_REPO/CLAUDE.md" CLAUDE.md
  # Update the branch and task fields
  sed -i.bak "s|Active branch / task:.*|Active branch / task: \`${BRANCH_NAME}\` — [fill in task description]|" CLAUDE.md
  rm -f CLAUDE.md.bak
  echo "Copied: CLAUDE.md (update Active Task table)"
fi

# ── Copy MEMORY.md ────────────────────────────────────────────────────────────

if [ ! -f MEMORY.md ]; then
  cp "$CORE_REPO/MEMORY.md" MEMORY.md
  echo "Copied: MEMORY.md"
fi

# ── Create project structure ──────────────────────────────────────────────────

mkdir -p quality_reports/{plans,session-logs}

# Symlink templates from core
if [ ! -L templates ]; then
  ln -s "$CORE_REPO/templates" templates
  echo "Linked: templates → $CORE_REPO/templates"
fi

# ── Domain-specific structure ─────────────────────────────────────────────────

case "$BRANCH_TYPE" in
  research)
    mkdir -p slides related_work output/figures preambles
    echo "Created: research structure (slides/, related_work/, output/figures/)"
    ;;
  analysis)
    mkdir -p data/{raw,processed} output/{figures,tables,reports} scripts/notebooks
    echo "Created: analysis structure (data/, output/, scripts/notebooks/)"
    ;;
  dev)
    mkdir -p src tests docs scripts
    echo "Created: dev structure (src/, tests/, docs/)"
    ;;
  exploration)
    mkdir -p explorations output
    echo "Created: exploration structure (explorations/, output/)"
    ;;
esac

# ── .mcp.json (project-scoped MCP: filesystem only) ──────────────────────────
# GitHub and web search are user-scoped in ~/.claude.json — set up once per machine.
# See docs/mcp-setup-macos.md for instructions.

if [ ! -f .mcp.json ]; then
  EXPANDED_ROOT=$(cd "$PROJECT_ROOT" && pwd)
  cat > .mcp.json << EOF
{
  "_doc": "Project-scoped MCP. GitHub + web search are user-scoped in ~/.claude.json (see docs/mcp-setup-macos.md).",
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "${EXPANDED_ROOT}"
      ]
    }
  }
}
EOF
  echo "Created: .mcp.json (filesystem server scoped to $EXPANDED_ROOT)"
fi

# ── .gitignore ────────────────────────────────────────────────────────────────

if [ ! -f .gitignore ]; then
  cat > .gitignore << 'EOF'
# Build artifacts
*.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg

# Python
__pycache__/ *.pyc .ipynb_checkpoints/ .mypy_cache/ .ruff_cache/

# Data (raw data is often too large for git)
data/raw/

# Secrets
.env .env.* secrets/

# macOS
.DS_Store

# Snapshots (auto-generated)
.claude/snapshots/
EOF
  echo "Created: .gitignore"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "✓ Task branch ready: $BRANCH_NAME"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_ROOT"
echo "  2. Update CLAUDE.md — fill in task description and Active Task table"
echo "  3. Run: claude"
echo "  4. Type: /start-task"
echo ""
echo "MCP servers:"
echo "  Filesystem: active in .mcp.json (scoped to $EXPANDED_ROOT)"
echo "  GitHub + web search: set up once with docs/mcp-setup-macos.md (user-scoped)"
echo ""
echo "To add task-specific agents:  .claude/agents/your-agent.md"
echo "To add task-specific skills:  .claude/commands/your-skill.md"
