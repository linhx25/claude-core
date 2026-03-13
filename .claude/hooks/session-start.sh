#!/usr/bin/env bash
# session-start.sh
# Fires when a new session starts or is resumed.
# Outputs MEMORY.md and personal.md to stdout → Claude sees them as context.

set -euo pipefail

PROJ="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Inject MEMORY.md if it has any LEARN entries
MEMORY_FILE="$PROJ/MEMORY.md"
if [ -f "$MEMORY_FILE" ] && grep -q "\[LEARN:" "$MEMORY_FILE" 2>/dev/null; then
  echo "=== SESSION CONTEXT: MEMORY.md (past learnings) ==="
  cat "$MEMORY_FILE"
  echo "=== END MEMORY.md ==="
fi

# Inject personal.md if present (gitignored, machine-specific)
PERSONAL_FILE="$HOME/.claude/personal.md"
if [ -f "$PERSONAL_FILE" ] && [ -s "$PERSONAL_FILE" ]; then
  echo "=== SESSION CONTEXT: personal.md (your local preferences) ==="
  cat "$PERSONAL_FILE"
  echo "=== END personal.md ==="
fi

# Report latest plan snapshot if available (macOS-compatible)
SNAPSHOTS_DIR="$PROJ/.claude/snapshots"
LATEST_SNAPSHOT=$(ls -t "$SNAPSHOTS_DIR"/plan_*.md 2>/dev/null | head -1 || true)
if [ -n "$LATEST_SNAPSHOT" ]; then
  FILE_TIME=$(date -r "$LATEST_SNAPSHOT" +%s 2>/dev/null || date +%s)
  NOW=$(date +%s)
  SNAPSHOT_AGE=$(( (NOW - FILE_TIME) / 60 ))
  echo "Note: Plan snapshot available from ${SNAPSHOT_AGE}m ago → $LATEST_SNAPSHOT"
fi

exit 0