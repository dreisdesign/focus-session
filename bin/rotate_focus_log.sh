#!/usr/bin/env zsh
# Rotate the focus session log into a dated archive directory
# Moves /tmp/watch_inactivity_simple.log -> ~/Library/Logs/focus-session/focus-session-YYYY-MM-DD-HHMMSS.log.gz

LOG="/tmp/watch_inactivity_simple.log"
ARCHIVE_DIR="$HOME/Library/Logs/focus-session"

mkdir -p "$ARCHIVE_DIR"

if [[ -f "$LOG" && -s "$LOG" ]]; then
  # convert to CSV for today's archive
  if [[ -x "$(dirname "$LOG")" ]] || true; then
    /bin/zsh "$(dirname "$0")/log_to_csv.sh" 2>/dev/null || true
  fi
  ts=$(date +%F-%H%M%S)
  dest="$ARCHIVE_DIR/focus-session-$ts.log"
  mv "$LOG" "$dest"
  gzip -f "$dest"
fi

# recreate an empty live log so the watcher keeps writing
:> "$LOG"

exit 0
