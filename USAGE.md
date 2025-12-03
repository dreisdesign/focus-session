# Focus Session Watcher - Usage Guide

## Initial Setup

### Import Required Shortcuts

Before using the watcher, import these shortcuts by clicking the links and adding them to your Shortcuts app:

1. **[focus-session--script_macos](https://www.icloud.com/shortcuts/1ec30ee610c14db68af3621971000993)** - Click and add to Shortcuts
2. **[focus-session--script-alert_macos](https://www.icloud.com/shortcuts/55c84ca1e2494e5598dd1201f83c03b2)** - Click and add to Shortcuts
3. (Optional) **[focus-session--script-status_macos](https://www.icloud.com/shortcuts/fa0f9e41125b499b8fe74705109b0d6d)** - For viewing session status

After importing, restart the watcher:
```bash
kill $(pgrep -f watch_inactivity_simple)
# Wait 2 seconds for LaunchAgent to auto-restart
```

---

## Quick Reference

### Check Status
```bash
# Show current session countdown (MM:SS format)
cat ~/focus-session-status.txt
# Output: "25:00", "12:34", "00:05", or "Inactive"

# Show detailed active session info
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh active-session
# Output:
# --- Active Session ---
# Start: 3:16PM
# End:   3:41PM
#
# Time left: 23 minutes, 37 seconds
```

### View Logs
```bash
# Real-time log viewing (press Ctrl+C to exit)
tail -f /tmp/watch_inactivity_simple.log

# Last 20 log entries
tail -20 /tmp/watch_inactivity_simple.log

# Search for specific events
grep "Session start" /tmp/watch_inactivity_simple.log
grep "Shortcut completed" /tmp/watch_inactivity_simple.log

# Count completed sessions today
grep -c "Session end" /tmp/watch_inactivity_simple.log

# Open log in TextEdit
bash ~/Library/Application\ Support/focus-session/installer/bin/open_focus_log.sh
```

### Manage Services
```bash
# Restart the watcher (apply configuration changes)
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# Check if watcher is running
ps aux | grep watch_inactivity_simple | grep -v grep

# View watcher process details
ps -o pid,user,vsz,rss,time,command | grep watch_inactivity

# Get process ID
pgrep -f watch_inactivity_simple

# Kill watcher (careful!)
pkill -f watch_inactivity_simple
```

---

## Configuration Guide

### Change Session Duration

**Scenario**: I want 10-minute sessions instead of 25 minutes

```bash
# 1. Edit the main watcher script
nano ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh

# 2. Find line ~46 (search with Ctrl+W in nano):
#    SESSION_SECONDS=${SESSION_SECONDS:-1500}

# 3. Change 1500 to 600 (10 minutes = 600 seconds)
#    SESSION_SECONDS=${SESSION_SECONDS:-600}

# 4. Save (Ctrl+X, Y, Enter)

# 5. Update the status helper script to match:
nano ~/Library/Application\ Support/focus-session/installer/bin/active_session.sh

# 6. Find line ~10:
#    SESSION_SECONDS=${SESSION_SECONDS:-1500}

# 7. Change to same value:
#    SESSION_SECONDS=${SESSION_SECONDS:-600}

# 8. Save and restart watcher
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh
```

**Common session durations**:
- `10` - 10 seconds (testing)
- `60` - 1 minute (break sessions)
- `300` - 5 minutes (quick sessions)
- `600` - 10 minutes (short work blocks)
- `1500` - 25 minutes (standard Pomodoro) ⭐ default
- `2700` - 45 minutes (deep work)
- `3600` - 1 hour (extended focus)

### Change Idle Threshold

**Scenario**: I want only 30 seconds of inactivity to reset the session

```bash
# 1. Edit the main watcher script
nano ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh

# 2. Find line ~10:
#    IDLE_THRESHOLD=120

# 3. Change 120 to 30:
#    IDLE_THRESHOLD=30

# 4. Save and restart
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh
```

**Common idle thresholds**:
- `10` - 10 seconds (very sensitive, for testing)
- `20` - 20 seconds (testing)
- `60` - 1 minute
- `120` - 2 minutes (default) ⭐
- `180` - 3 minutes
- `300` - 5 minutes (lenient)

### Test Configuration Before Saving

```bash
# Test with 10-second sessions and 20-second idle threshold
export SESSION_SECONDS=10
export IDLE_THRESHOLD=20

# Start the watcher manually
bash ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh

# In another terminal, monitor status
watch -n 1 'cat ~/focus-session-status.txt'

# Stop watcher when done (Ctrl+C)
# Then stop from other terminal with Ctrl+C
```

---

## Data Management

### View Daily CSV Data

```bash
# View today's session data (CSV format)
cat ~/Library/Logs/focus-session/focus-session-$(date +%F).csv

# View a specific day (e.g., Dec 1, 2025)
cat ~/Library/Logs/focus-session/focus-session-2025-12-01.csv

# List all available days
ls ~/Library/Logs/focus-session/focus-session-*.csv

# View in Excel-friendly format
column -t -s, ~/Library/Logs/focus-session/focus-session-$(date +%F).csv
```

### Analyze Your Focus Data

```bash
# Count completed sessions today
awk -F, 'NR>1 && $9==1 {count++} END {print "Completed sessions:", count}' \
  ~/Library/Logs/focus-session/focus-session-$(date +%F).csv

# Calculate total focus time today (in hours)
awk -F, 'NR>1 && $9==1 {total+=$8} END {print "Total focus time (hours):", total/3600}' \
  ~/Library/Logs/focus-session/focus-session-$(date +%F).csv

# Calculate average session length (in minutes)
awk -F, 'NR>1 && $9==1 {total+=$8; count++} END {print "Avg session (min):", total/count/60}' \
  ~/Library/Logs/focus-session/focus-session-$(date +%F).csv

# Show all sessions with start/end times
awk -F, 'NR>1 {print $1": "$4" → "$7" ("$8"s)"}' \
  ~/Library/Logs/focus-session/focus-session-$(date +%F).csv

# Find when you're most productive (most completed sessions by hour)
awk -F, 'NR>1 && $9==1 {
  cmd = "date -r "$2" +%H"
  cmd | getline hour
  close(cmd)
  count[hour]++
}
END {
  for (h in count) {
    print "Hour " h ": " count[h] " sessions"
  }
}' ~/Library/Logs/focus-session/focus-session-$(date +%F).csv | sort -t: -k2 -nr
```

### Export Data for Analysis

```bash
# Combine all CSVs into one master file
cat ~/Library/Logs/focus-session/focus-session-*.csv > all-sessions-master.csv

# Remove duplicate headers (keep only first)
head -1 all-sessions-master.csv > all-sessions.csv
tail -n +2 all-sessions-master.csv | grep -v "^session," >> all-sessions.csv
rm all-sessions-master.csv

# Now import into Excel, Numbers, or Google Sheets
# (open all-sessions.csv in your spreadsheet app)

# Weekly summary
awk -F, '
  NR>1 && $9==1 {
    cmd = "date -r "$2" +%Y-W%V"
    cmd | getline week
    close(cmd)
    sessions[week]++
    time[week]+=$8
  }
  END {
    for (w in sessions) {
      print w ": " sessions[w] " sessions, " time[w]/60/60 " hours"
    }
  }' all-sessions.csv | sort
```

### Backup and Archive

```bash
# Backup all logs
tar -czf focus-session-backup-$(date +%Y%m%d).tar.gz \
  ~/Library/Logs/focus-session/ \
  ~/focus-session-status.txt

# Archive logs older than 90 days to external drive
find ~/Library/Logs/focus-session/ -name "*.csv" -mtime +90 -exec \
  cp {} /Volumes/ExternalDrive/archives/ \;

# Delete local logs older than 365 days
find ~/Library/Logs/focus-session/ -name "*.csv" -mtime +365 -delete
```

---

## Shortcuts Integration

### Test Shortcut Manually

```bash
# Test "start" alert
shortcuts run "script_mac--inactivity_shared" --input "start"

# Test "end" alert
shortcuts run "script_mac--inactivity_shared" --input "end"

# Test status display (no input)
shortcuts run "script_mac--inactivity_shared"
```

### Custom Shortcut Actions

The bundled Shortcut responds to three inputs:

| Input | Action |
|-------|--------|
| `start` | Shows "Focus session started" alert |
| `end` | Shows "Lock screen?" alert and locks screen |
| (blank) | Shows current session status (TEST mode) |

You can customize messages by editing the Shortcut in the Shortcuts app.

### Focus Mode Handling

If Focus Mode is active when the session ends:
1. Shortcut shows menu: "You have a focus mode enabled"
2. Options:
   - "Continue as normal" - Lock screen immediately
   - "Pause alerts until focus turned off" - Creates pause marker file

The pause marker is stored in iCloud Drive at `~/Shortcuts/focus-session-paused.txt`.

---

## Performance & Optimization

### Monitor Resource Usage

```bash
# Check CPU and memory usage
ps aux | grep watch_inactivity | grep -v grep | awk '{print "CPU: "$3"%, Memory: "$6" KB"}'

# Monitor in real-time (press Ctrl+C to exit)
top -p $(pgrep -f watch_inactivity_simple)

# Check disk space used by logs
du -sh ~/Library/Logs/focus-session/
```

**Expected usage**:
- **CPU**: ~0% (only polls every 2 seconds)
- **Memory**: 1-2 MB
- **Disk**: ~100 KB per day of logs
- **Battery**: Negligible impact

### Clean Up Old Logs

```bash
# See how much space logs are using
du -sh ~/Library/Logs/focus-session/

# Delete logs older than 6 months
find ~/Library/Logs/focus-session/ -name "*.csv" -mtime +180 -delete
find ~/Library/Logs/focus-session/ -name "*.log.gz" -mtime +180 -delete

# Keep only last 90 days
find ~/Library/Logs/focus-session/ -name "*.csv" -mtime +90 -exec rm {} \;
```

---

## Integration with Other Tools

### Use Status in Other Shortcuts

Get the current focus time in any Shortcut:

```bash
# In Shortcuts app, use "Run Shell Script":
cat ~/focus-session-status.txt

# Then use "Ask for [Number, Text]" to display it
```

### Pipe to System Notifications

```bash
# Create a persistent notification (requires third-party app)
# Or use Shortcuts to display the status

# Example: Display status every minute
while true; do
  STATUS=$(cat ~/focus-session-status.txt)
  osascript -e "display notification \"$STATUS\" with title \"Focus\""
  sleep 60
done
```

### Log to External Services

```bash
# Example: Send focus completion to a webhook
# Add to Shortcut or create separate automation

curl -X POST https://your-webhook-url.com/focus \
  -H "Content-Type: application/json" \
  -d "{
    \"event\": \"session_end\",
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"duration\": \"1500\"
  }"
```

---

## Tips & Tricks

### Display Status in Menu Bar

You can use third-party tools like Platypus, SwiftBar, or BitBar to display `focus-session-status.txt` in your menu bar:

```bash
# For BitBar/SwiftBar, create ~/Library/Application\ Support/SwiftBar/Plugins/focus.1m.sh
#!/bin/bash
cat ~/focus-session-status.txt
```

Then enable the plugin in SwiftBar preferences.

### Create a Quick Status Menu

```bash
# Create an alias for quick status checks
echo 'alias focus="cat ~/focus-session-status.txt"' >> ~/.zshrc
source ~/.zshrc

# Now just type: focus
```

### Calendar Integration

Export focus sessions to calendar:

```bash
# Create ICS file of today's sessions
bash ~/Library/Application\ Support/focus-session/installer/bin/log_to_csv.sh

# Convert CSV to calendar format (requires custom script)
# This is a good opportunity to write your own automation!
```

---

## Frequently Asked Questions

**Q: How do I know the watcher is running?**
```bash
ps aux | grep watch_inactivity_simple | grep -v grep
```
If you see a process, it's running!

**Q: Can I have multiple watcher instances?**
No, the script prevents duplicates using atomic locks (`/tmp/watch_inactivity_simple.lock`).

**Q: Does this work on Apple Silicon Macs?**
Yes! The scripts use only built-in macOS tools (`ioreg`, `launchctl`, `zsh`).

**Q: Can I customize the Shortcut alerts?**
Yes! Open the Shortcut in the Shortcuts app and edit the alert messages.

**Q: How much battery does this use?**
Negligible - the watcher sleeps most of the time, only polling every 2 seconds.

**Q: Can I use this on iOS?**
No, this is macOS-only due to LaunchAgent and HID device requirements.

---

## Need Help?

1. Check `TROUBLESHOOTING.md` for common issues
2. View logs: `tail -f /tmp/watch_inactivity_simple.log`
3. Check GitHub Issues: https://github.com/yourusername/focus-session-installer/issues
4. View all status info: `bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh`
