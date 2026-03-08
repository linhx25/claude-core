#!/usr/bin/env bash
# pre-compact.sh
# Fires before Claude auto-compresses context.
# Saves current plan so it survives compression.

set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SNAPSHOT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/snapshots"
mkdir -p "$SNAPSHOT_DIR"

# Save current plan if it exists
PLAN_FILE="${CLAUDE_PROJECT_DIR:-$(pwd)}/quality_reports/plans/CURRENT_PLAN.md"
if [ -f "$PLAN_FILE" ]; then
  cp "$PLAN_FILE" "$SNAPSHOT_DIR/plan_${TIMESTAMP}.md"
  echo "pre-compact: saved plan snapshot → .claude/snapshots/plan_${TIMESTAMP}.md"
fi

# Save MEMORY.md snapshot
MEMORY_FILE="${CLAUDE_PROJECT_DIR:-$(pwd)}/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
  cp "$MEMORY_FILE" "$SNAPSHOT_DIR/memory_${TIMESTAMP}.md"
  echo "pre-compact: saved memory snapshot → .claude/snapshots/memory_${TIMESTAMP}.md"
fi

# Keep only the 10 most recent snapshots of each type to avoid clutter
ls -t "$SNAPSHOT_DIR"/plan_*.md 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
ls -t "$SNAPSHOT_DIR"/memory_*.md 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true

exit 0
