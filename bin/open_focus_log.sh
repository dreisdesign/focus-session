#!/usr/bin/env zsh
# Open the focus session log in TextEdit (safe for Shortcuts)
LOG_FILE="/tmp/watch_inactivity_simple.log"

if [[ ! -f "$LOG_FILE" ]]; then
  # create an empty log with a header so TextEdit opens a file
  mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
  echo "Focus session log created at $(date)" > "$LOG_FILE"
fi

# Use TextEdit (GUI) so Shortcuts will open a visible window
open -a TextEdit "$LOG_FILE"
