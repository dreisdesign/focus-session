#!/usr/bin/env zsh
# Prints an "Active Session" block:
# --- Active Session ---
# Start: H:MMAM/PM
# End: H:MMAM/PM
#
# Time left: X minutes, YY seconds

SESSION_SECONDS=${SESSION_SECONDS:-1500}    # match watcher script (default: 1500 for 25 min)
STATE_FILE="/tmp/watch_inactivity_state.json"
LOG_FILE="/tmp/watch_inactivity_simple.log"

now_epoch=$(date +%s)

# Helper: format epoch -> H:MMAM/PM
format_time() {
  if [[ -n "$1" && "$1" -gt 0 ]]; then
    date -r "$1" "+%l:%M%p" 2>/dev/null | sed 's/^ //'
  else
    echo "--"
  fi
}

# 1) Try to read session_start from state JSON
session_start=0
if [[ -f "$STATE_FILE" ]]; then
  session_start=$(grep -oE '"session_start"[[:space:]]*:[[:space:]]*[0-9]+' "$STATE_FILE" 2>/dev/null \
    | sed -E 's/[^0-9]*([0-9]+).*/\1/')
  session_start=${session_start:-0}
fi

# 2) Fallback: most recent "Session start" from log
if [[ -z "$session_start" || "$session_start" -eq 0 ]]; then
  if [[ -f "$LOG_FILE" ]]; then
    session_start=$(grep -F "Session start" "$LOG_FILE" 2>/dev/null \
      | grep -oE '[0-9]{9,}' | sort -n | tail -n 1)
    session_start=${session_start:-0}
  fi
fi

# If still no session_start, print no active session
if [[ -z "$session_start" || "$session_start" -eq 0 ]]; then
  echo "--- Active Session ---"
  echo "No active session"
  exit 0
fi

session_end=$(( session_start + SESSION_SECONDS ))
# Consider active only if now < session_end
if (( now_epoch >= session_end )); then
  echo "--- Active Session ---"
  echo "No active session (last session finished at $(format_time "$session_end"))"
  exit 0
fi

# Compute remaining time
rem=$(( session_end - now_epoch ))
min=$(( rem / 60 ))
sec=$(( rem % 60 ))

# pluralization
min_label="minutes"
sec_label="seconds"
if (( min == 1 )); then min_label="minute"; fi
if (( sec == 1 )); then sec_label="second"; fi

# Output block
echo "--- Active Session ---"
echo "Start: $(format_time "$session_start")"
echo "End:   $(format_time "$session_end")"
echo
echo "Time left: ${min} ${min_label}, $(printf "%02d" "$sec") ${sec_label}"
