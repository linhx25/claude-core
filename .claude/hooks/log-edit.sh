#!/usr/bin/env bash
# log-edit.sh
# Fires after Write/Edit/MultiEdit tool calls.
# Appends a brief record to the current session log.

set -euo pipefail

INPUT=$(cat)

# Extract the file path from the tool input JSON
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
tool_input = data.get('tool_input', {})
# Write uses 'file_path', Edit uses 'path'
print(tool_input.get('file_path') or tool_input.get('path') or 'unknown')
" 2>/dev/null || echo "unknown")

TOOL_NAME=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data.get('tool_name', 'Edit'))
" 2>/dev/null || echo "Edit")

TIMESTAMP=$(date +%H:%M:%S)
LOG_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/quality_reports/session-logs"
mkdir -p "$LOG_DIR"

# Write to today's session log
TODAY=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/session_${TODAY}.log"
echo "[$TIMESTAMP] $TOOL_NAME → $FILE_PATH" >> "$LOG_FILE"

exit 0
