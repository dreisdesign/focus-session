#!/bin/bash
# Minimal inactivity watcher for macOS
# Sends 'start' to Shortcuts CLI after IDLE_THRESHOLD seconds of inactivity

IDLE_THRESHOLD=120  # seconds (default for normal use)
SHORTCUT_NAME="script_mac--inactivity_shared"
INPUT_FILE="/tmp/shortcut_input.txt"
LOG_FILE="/tmp/watch_inactivity_simple.log"

# Small startup delay to avoid running too early under launchd
STARTUP_DELAY=3
sleep $STARTUP_DELAY

# Produce readable timestamps like: "Fri Sep 19 2025 2:16PM"
pretty_ts() {
    # Use 12-hour hour field (%l) which may be space-padded for single-digit hours
    # then normalize multiple spaces down to one.
    date '+%a %b %d %Y %l:%M%p' | sed -E 's/  +/ /g'
}

# Run shortcuts with timeout to prevent hanging
run_shortcut() {
    local input_type="$1"
    local timeout_secs=10
    
    echo "$input_type" > "$INPUT_FILE"
    echo "[$(pretty_ts)] Triggering shortcut with input: $input_type" >> "$LOG_FILE"
    
    if [ -n "$TEST_MODE" ]; then
        echo "TEST: shortcuts run '$SHORTCUT_NAME' --input-path '$INPUT_FILE'" >> "$LOG_FILE"
        return 0
    fi
    
    # Run with timeout using background process
    shortcuts run "$SHORTCUT_NAME" --input-path "$INPUT_FILE" >> "$LOG_FILE" 2>&1 &
    local shortcut_pid=$!
    
    # Wait for timeout or completion
    local elapsed=0
    while kill -0 $shortcut_pid 2>/dev/null && [ $elapsed -lt $timeout_secs ]; do
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    # Check if still running and kill if necessary
    if kill -0 $shortcut_pid 2>/dev/null; then
        echo "[$(pretty_ts)] WARNING: Shortcut timed out after ${timeout_secs}s, killing..." >> "$LOG_FILE"
        kill -TERM $shortcut_pid 2>/dev/null
        sleep 1
        kill -9 $shortcut_pid 2>/dev/null
        return 1
    fi
    
    # Wait for actual exit status
    wait $shortcut_pid 2>/dev/null
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "[$(pretty_ts)] Shortcut completed successfully" >> "$LOG_FILE"
    else
        echo "[$(pretty_ts)] WARNING: Shortcut exited with code $exit_code" >> "$LOG_FILE"
    fi
    
    return $exit_code
}

# Force session start immediately after startup (login/unlock)
now=$(date '+%s')
session_start="$now"
run_shortcut "start"
echo "Session start: $(pretty_ts) [forced at startup]" >> "$LOG_FILE"
triggered=0


get_idle() {
    # Try a few times to get HIDIdleTime from ioreg; if it fails, return a value
    # greater than IDLE_THRESHOLD so the script treats it as idle and doesn't
    # incorrectly trigger activity.
    for i in 1 2 3; do
        idle_raw=$(ioreg -c IOHIDSystem 2>/dev/null | awk '/HIDIdleTime/ {print $NF; exit}')
        if [ -n "$idle_raw" ]; then
            # Convert nanoseconds to seconds (floating) and print integer seconds
            echo $((idle_raw/1000000000))
            return
        fi
        sleep 1
    done
    # fallback: indicate idle
    echo $((IDLE_THRESHOLD + 1))
}


# Session logic variables
SESSION_SECONDS=${SESSION_SECONDS:-1500}  # session duration in seconds (default: 1500 for 25 min)
POLL_INTERVAL=2
session_start=""
triggered=0

# Test hooks: if TEST_SESSION_SECONDS is set, use that as the session limit (seconds).
# If TEST_MODE is set (non-empty), the script will not call `shortcuts run` or lock the screen;
# instead it logs the actions for safe testing.
if [ -n "$TEST_SESSION_SECONDS" ]; then
    SESSION_LIMIT=$TEST_SESSION_SECONDS
else
    SESSION_LIMIT=$SESSION_SECONDS
fi

# PIDfile/lock handling using an atomic directory create to avoid races
PIDFILE="/tmp/watch_inactivity_simple.pid"
LOCKDIR="/tmp/watch_inactivity_simple.lock"

# Try to acquire lock by creating a lock directory (mkdir is atomic)
if mkdir "$LOCKDIR" 2>/dev/null; then
    # We acquired the lock; write our pid
    echo $$ > "$PIDFILE" || { rmdir "$LOCKDIR" 2>/dev/null; echo "Failed to write pidfile" >> "$LOG_FILE"; exit 1; }
else
    # Lock exists; check if pidfile points to a running process
    oldpid=$(cat "$PIDFILE" 2>/dev/null || echo "")
    if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
        echo "Watcher already running (PID $oldpid). Exiting." >> "$LOG_FILE"
        exit 0
    fi
    # Stale lockdir or pid; attempt to remove and acquire
    if rmdir "$LOCKDIR" 2>/dev/null && mkdir "$LOCKDIR" 2>/dev/null; then
        echo $$ > "$PIDFILE" || { rmdir "$LOCKDIR" 2>/dev/null; echo "Failed to write pidfile" >> "$LOG_FILE"; exit 1; }
    else
        echo "Watcher lock present and could not be acquired. Exiting." >> "$LOG_FILE"
        exit 0
    fi
fi
trap 'rm -f "$PIDFILE"; rmdir "$LOCKDIR" 2>/dev/null' EXIT


# Path to CGSession (lock screen helper); guard before calling
CGSESSION_CMD="/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"

# Improved session logic: only send 'start' once per session, track activity, trigger 'end' after 25 minutes
while true; do
    idle=$(get_idle)
    now=$(date '+%s')

    # If idle >= threshold, reset session and wait for activity
    if [ "$idle" -ge $IDLE_THRESHOLD ]; then
        if [ -n "$session_start" ]; then
            echo "Session reset due to inactivity: $(pretty_ts)" >> "$LOG_FILE"
        fi
        session_start=""
        triggered=0
        sleep $POLL_INTERVAL
        continue
    fi

    # If session not started, start it and send 'start' only once
    if [ -z "$session_start" ]; then
        session_start="$now"
        run_shortcut "start"
        echo "Session start: $(pretty_ts)" >> "$LOG_FILE"
        triggered=0
    fi

    # If session running and not yet triggered, check for 25 minutes of continuous activity
    elapsed=$((now - session_start))
    if [ "$triggered" -eq 0 ] && [ "$elapsed" -ge "$SESSION_LIMIT" ]; then
        run_shortcut "end"
        echo "Session end: $(pretty_ts)" >> "$LOG_FILE"
        # Lock the screen if lock helper exists; otherwise log that it's unavailable
        if [ -n "$TEST_MODE" ]; then
            echo "TEST: would call lock command: $CGSESSION_CMD -suspend" >> "$LOG_FILE"
        else
            if [ -x "$CGSESSION_CMD" ]; then
                "$CGSESSION_CMD" -suspend
            else
                echo "Lock command not available: $CGSESSION_CMD" >> "$LOG_FILE"
            fi
        fi
        triggered=1
        session_start=""  # Reset session so new session can start after inactivity/unlock
    fi

    # Write session status for Shortcut access (MM:SS)
    if [ -n "$session_start" ] && [ "$triggered" -eq 0 ]; then
        total_seconds_left=$((SESSION_LIMIT - elapsed))
        if [ "$total_seconds_left" -lt 0 ]; then
            total_seconds_left=0
        fi
        mins_left=$((total_seconds_left / 60))
        secs_left=$((total_seconds_left % 60))
        printf "%02d:%02d" "$mins_left" "$secs_left" > "$HOME/focus-session-status.txt"
    else
        echo "Inactive" > "$HOME/focus-session-status.txt"
    fi

    # Optional: exit if user disables watcher
    [ -f "$HOME/shortcuts-scripts/.disable_watcher" ] && exit 0
    # Optional: rotate log if >1MB
    [ -f "$LOG_FILE" ] && [ $(stat -f %z "$LOG_FILE") -gt 1048576 ] && mv "$LOG_FILE" "$LOG_FILE.old"
        # Write JSON state for compatibility with legacy status helpers
        STATE_FILE="/tmp/watch_inactivity_state.json"
        # session_start can be empty; write 0 in that case
        ss_val=0
        if [ -n "$session_start" ]; then ss_val=$session_start; fi
        cat > "$STATE_FILE" <<EOF
{
    "timestamp": $(date '+%s'),
    "idle_seconds": $idle,
    "triggered": $triggered,
    "session_start": $ss_val
}
EOF
    sleep $POLL_INTERVAL
done
