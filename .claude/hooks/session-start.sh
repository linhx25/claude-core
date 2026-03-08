#!/usr/bin/env bash
# session-start.sh
# Fires when a new session starts or is resumed.
# Outputs MEMORY.md content to stdout → Claude sees it as context.

set -euo pipefail

MEMORY_FILE="${CLAUDE_PROJECT_DIR:-$(pwd)}/MEMORY.md"

# User-level personal.md (preferred — true across all projects)
PERSONAL_FILE="${CLAUDE_PROJECT_DIR:-$(pwd)}/personal.md"

if [ -f "$MEMORY_FILE" ] && [ -s "$MEMORY_FILE" ]; then
  # Only inject if there are actual LEARN entries
  if grep -q "\[LEARN:" "$MEMORY_FILE" 2>/dev/null; then
    echo "=== SESSION CONTEXT: MEMORY.md (past learnings) ==="
    cat "$MEMORY_FILE"
    echo "=== END MEMORY.md ==="
  fi
fi

# Report latest plan snapshot if available
LATEST_SNAPSHOT=$(ls -t "${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/snapshots"/plan_*.md 2>/dev/null | head -1)
if [ -n "$LATEST_SNAPSHOT" ]; then
  SNAPSHOT_AGE=$(( ($(date +%s) - $(stat -c %Y "$LATEST_SNAPSHOT" 2>/dev/null || stat -f %m "$LATEST_SNAPSHOT" 2>/dev/null || echo 0)) / 60 ))
  echo "Note: Plan snapshot available from ${SNAPSHOT_AGE}m ago → $LATEST_SNAPSHOT"
fi

exit 0
