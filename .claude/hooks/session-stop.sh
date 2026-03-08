#!/usr/bin/env bash
# session-stop.sh
# Fires when Claude finishes responding (Stop event).
# Outputs a reminder to stdout if session log has content.
# Claude sees this as context for its final response.

set -euo pipefail

LOG_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/quality_reports/session-logs"
TODAY=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/session_${TODAY}.log"

# Only remind if files were edited this session
if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
  EDIT_COUNT=$(wc -l < "$LOG_FILE")
  if [ "$EDIT_COUNT" -gt 3 ]; then
    echo "Session note: $EDIT_COUNT edits logged today. If you learned anything non-obvious, append it to MEMORY.md with a [LEARN:category] tag before ending the session."
  fi
fi

exit 0
