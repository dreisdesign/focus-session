# Focus Session Watcher - Troubleshooting Guide

## Quick Diagnostics

Run this to get a full system status:

```bash
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh
```

This will show you:
- ✓ Current process status
- ✓ Session countdown
- ✓ Recent log entries
- ✓ Any errors

---

## Issue 1: Watcher Not Running

### Symptom
- No process running
- `~/focus-session-status.txt` doesn't exist or isn't updating

### Diagnosis

```bash
# Check if process exists
ps aux | grep watch_inactivity_simple | grep -v grep

# Check LaunchAgent status
launchctl list | grep watch_inactivity

# Check for errors
cat /tmp/watch_inactivity_simple.launch.err.log
```

### Solution

```bash
# Option 1: Restart via LaunchAgent
launchctl load ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# Option 2: Full restart
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# Option 3: Manual start (for testing)
bash ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh
```

### If Still Not Working

```bash
# 1. Check if plist is valid
plutil -lint ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# 2. Check file permissions
ls -la ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
# Should show: -rw-r--r--

# 3. Fix permissions if needed
chmod 644 ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# 4. Check script file permissions
ls -la ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh
# Should show: -rwxr-xr-x (with x for execute)

# 5. Fix if needed
chmod +x ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh

# 6. Reload
launchctl unload ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
launchctl load ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
```

---

## Issue 2: Session Not Starting After Activity

### Symptom
- Watcher is running
- But sessions aren't starting when you use the computer
- `~/focus-session-status.txt` shows "Inactive"

### Diagnosis

```bash
# Check idle time detection
ioreg -c IOHIDSystem | grep HIDIdleTime

# If low (e.g., < 5 seconds): You're actively using the computer ✓
# If high (e.g., > 120 seconds): You're idle (watcher correctly resets)

# Check current watcher state
cat /tmp/watch_inactivity_state.json

# Check log for activity detection
tail -30 /tmp/watch_inactivity_simple.log | grep -E "Session|idle|Triggering"
```

### Solution

```bash
# 1. Generate some activity
# Click mouse, type on keyboard for a few seconds

# 2. Wait a moment (up to 4 seconds, since poll interval is 2s)
sleep 5

# 3. Check status again
cat ~/focus-session-status.txt

# 4. If still "Inactive", check idle detection:
ioreg -c IOHIDSystem | grep HIDIdleTime

# If HIDIdleTime is still high, try:
# - Using the trackpad more
# - Typing in a text editor
# - Moving the mouse around
```

### If idle detection is broken

```bash
# Check system event tracking
log stream --predicate 'eventMessage contains[cd] "HID"' --level debug

# Try alternative idle check
# (The ioreg method is the most reliable)

# Restart watcher
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh
```

---

## Issue 3: Shortcut Not Triggering / Not Found

### Symptom
- Log shows "WARNING: Shortcut timed out" or "No such file or directory"
- Session doesn't trigger alerts
- Screen doesn't lock

### Diagnosis

```bash
# Check if Shortcut is installed
shortcuts list | grep -i "inactivity\|focus"

# Test Shortcut manually
shortcuts run "script_mac--inactivity_shared" --input "start"

# Check logs for specific errors
grep -i "shortcut\|warning\|error" /tmp/watch_inactivity_simple.log | tail -10
```

### Solution

**Step 1: Verify Shortcut is Imported**

```bash
# List all shortcuts
shortcuts list

# Look for "script_mac--inactivity_shared" in the output
# If not found, import it:
open ~/Library/Application\ Support/focus-session/installer/Shortcuts/script_mac--inactivity_shared.shortcut
```

**Step 2: Check Shortcuts Permissions**

Go to: **System Settings → Privacy & Security → Automation**

Check that **Shortcuts** is allowed to:
- Run scripts
- Control your computer

**Step 3: Test Shortcut**

```bash
# Test with 10-second timeout
timeout 10 shortcuts run "script_mac--inactivity_shared" --input "start"

# If error about "No such script", import the shortcut (Step 1)
```

**Step 4: Enable in Watcher Script**

Edit watcher script to verify Shortcuts is not disabled:

```bash
nano ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh

# Around line 35, check:
if [ -n "$TEST_MODE" ]; then
    # If TEST_MODE is set, shortcuts are disabled
    # To re-enable: unset TEST_MODE
fi
```

---

## Issue 4: Screen Not Locking

### Symptom
- Session completes
- "end" shortcut runs
- But screen doesn't lock

### Diagnosis

```bash
# Check if CGSession command exists
ls -la /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession

# Test lock command
/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend

# Check logs for lock command errors
grep -i "lock\|CGSession" /tmp/watch_inactivity_simple.log | tail -5
```

### Solution

**Option 1: Use Shortcut's Lock Feature** (Preferred)

Edit the Shortcut in the Shortcuts app:
1. Open "script_mac--inactivity_shared"
2. Find the "end" branch
3. Add "Lock screen" action if missing

**Option 2: Manual Lock**

```bash
# Lock screen manually (if auto-lock isn't working)
pmset displaysleepnow

# Or use:
/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
```

**Option 3: Check Focus Mode**

If Focus mode is active, macOS may prevent screen lock:

```bash
# Check active Focus modes
osascript -e 'tell application "System Events" to get name of application processes where background only is false' | grep -i "focus\|do not"

# Disable Focus mode and try again
```

---

## Issue 5: Duplicate Watcher Instances

### Symptom
- Log shows "Watcher already running (PID ...)"
- Multiple processes visible
- Session not working correctly

### Diagnosis

```bash
# Check for multiple processes
ps aux | grep watch_inactivity_simple | grep -v grep

# Check lock files
ls -la /tmp/watch_inactivity_simple.lock /tmp/watch_inactivity_simple.pid 2>/dev/null
```

### Solution

```bash
# 1. Kill all instances
pkill -9 -f watch_inactivity_simple

# 2. Remove lock files
rm -rf /tmp/watch_inactivity_simple.lock
rm -f /tmp/watch_inactivity_simple.pid

# 3. Clear temp files
rm -f /tmp/watch_inactivity_simple.log
rm -f /tmp/watch_inactivity_state.json

# 4. Restart watcher
launchctl unload ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
sleep 2
launchctl load ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# 5. Verify
sleep 2
ps aux | grep watch_inactivity_simple | grep -v grep
```

---

## Issue 6: Timeout Errors

### Symptom
- Log shows: "WARNING: Shortcut timed out after 10s"
- Shortcuts app hangs

### Diagnosis

```bash
# Check system load
uptime

# Test shortcut with timeout
timeout 15 shortcuts run "script_mac--inactivity_shared" --input "start"

# Check for Shortcuts app processes
ps aux | grep -i shortcuts | grep -v grep
```

### Solution

```bash
# 1. Give Shortcuts app more time (if system is slow)
#    Edit watch_inactivity_simple.sh, find:
timeout_secs=10  # Change to 20 or 30

# 2. Restart Shortcuts app
killall Shortcuts
sleep 2
open -a Shortcuts

# 3. Restart watcher
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# 4. If still timing out, enable TEST_MODE (skip Shortcuts):
export TEST_MODE=1
bash ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh
# (Only do this for testing - disables alerts!)
```

---

## Issue 7: Log Rotation Not Working

### Symptom
- Logs aren't being archived at 23:59
- No CSV files being created
- `/tmp/watch_inactivity_simple.log` growing indefinitely

### Diagnosis

```bash
# Check if rotation service is loaded
launchctl list | grep rotate_focus_log

# Check rotation script permissions
ls -la ~/Library/Application\ Support/focus-session/installer/bin/rotate_focus_log.sh

# Check plist validity
plutil -lint ~/Library/LaunchAgents/com.user.rotate_focus_log.plist
```

### Solution

```bash
# 1. Install rotation service
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh install-rotate

# 2. Verify it's loaded
launchctl list | grep rotate_focus_log

# 3. Manually rotate log
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh rotate

# 4. Check archive directory
ls -lh ~/Library/Logs/focus-session/ | head -5
```

---

## Issue 8: CSV Conversion Failing

### Symptom
- No `.csv` files being created
- Log shows errors from `log_to_csv.sh`

### Diagnosis

```bash
# Check if log has session markers
grep -c "Session start\|Session end" /tmp/watch_inactivity_simple.log

# Run CSV conversion manually
bash ~/Library/Application\ Support/focus-session/installer/bin/log_to_csv.sh

# Check output
ls -la ~/Library/Logs/focus-session/focus-session-$(date +%F).csv
```

### Solution

```bash
# 1. Check log format
tail -20 /tmp/watch_inactivity_simple.log | grep -E "Session (start|end)"

# Example correct format:
# Session start: Wed Dec 03 2025 1:21PM
# Session end: Wed Dec 03 2025 1:46PM

# 2. If format is wrong, restart watcher
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# 3. Let it run for a few minutes to generate new sessions
# (Do some work, wait for a session to complete)

# 4. Try manual CSV conversion again
bash ~/Library/Application\ Support/focus-session/installer/bin/log_to_csv.sh

# 5. If still failing, check script permissions
chmod +x ~/Library/Application\ Support/focus-session/installer/bin/log_to_csv.sh
```

---

## Issue 9: High CPU/Memory Usage

### Symptom
- Watcher using > 5% CPU
- Memory usage > 10 MB
- Fan running constantly

### Diagnosis

```bash
# Check actual usage
ps aux | grep watch_inactivity_simple | grep -v grep

# Monitor in real-time
top -p $(pgrep -f watch_inactivity_simple)

# Check system load
uptime
```

### Solution

**This is very rare.** The watcher should use < 0.5% CPU and < 2 MB memory.

If usage is high:

```bash
# 1. Check for stuck log file
ls -lh /tmp/watch_inactivity_simple.log

# If > 100 MB, rotate manually:
bash ~/Library/Application\ Support/focus-session/installer/bin/rotate_focus_log.sh

# 2. Check for duplicate processes (see Issue 5)
ps aux | grep watch_inactivity_simple | grep -v grep | wc -l

# 3. Check for too many Shortcuts processes
ps aux | grep -i shortcuts | wc -l

# 4. Restart everything
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh
```

---

## Issue 10: Status File Not Updating

### Symptom
- `~/focus-session-status.txt` exists but isn't changing
- Shows stale time (e.g., always "15:34")

### Diagnosis

```bash
# Check file modification time
stat ~/focus-session-status.txt

# Check file contents
cat ~/focus-session-status.txt

# Check if watcher is writing to it
tail -10 /tmp/watch_inactivity_simple.log | grep "status"
```

### Solution

```bash
# 1. Delete stale status file
rm -f ~/focus-session-status.txt

# 2. Restart watcher
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# 3. Wait a few seconds for file to be created
sleep 5

# 4. Verify it's updating
cat ~/focus-session-status.txt

# 5. Keep watching it
watch -n 1 'cat ~/focus-session-status.txt'
# (Press Ctrl+C to exit)
```

---

## Issue 11: Permission Denied Errors

### Symptom
- Errors like "Permission denied" in logs
- Watcher stops after a few seconds

### Diagnosis

```bash
# Check file permissions
ls -la ~/Library/Application\ Support/focus-session/installer/*.sh
ls -la ~/Library/Application\ Support/focus-session/installer/bin/*.sh

# Check plist permissions
ls -la ~/Library/LaunchAgents/com.user.*.plist
```

### Solution

```bash
# Fix script permissions (should be -rwxr-xr-x)
chmod +x ~/Library/Application\ Support/focus-session/installer/*.sh
chmod +x ~/Library/Application\ Support/focus-session/installer/bin/*.sh

# Fix plist permissions (should be -rw-r--r--)
chmod 644 ~/Library/LaunchAgents/com.user.*.plist

# Restart
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh
```

---

## Issue 12: LaunchAgent Fails to Load

### Symptom
- `launchctl load` shows error
- Plist won't load

### Diagnosis

```bash
# Validate plist file
plutil -lint ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# Try loading
launchctl load ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# Check for errors
launchctl list | grep watch_inactivity
```

### Solution

```bash
# 1. Unload first
launchctl unload ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist 2>/dev/null || true

# 2. Check plist validity
plutil -lint ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# 3. If invalid, reinstall:
cp ~/Library/Application\ Support/focus-session/installer/com.user.watch_inactivity_simple.plist \
   ~/Library/LaunchAgents/
chmod 644 ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# 4. Load again
launchctl load ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# 5. Verify
launchctl list | grep watch_inactivity
```

---

## Nuclear Option: Complete Reinstall

If nothing works, try a clean reinstall:

```bash
# 1. Uninstall completely
bash ~/Library/Application\ Support/focus-session/installer/uninstall.sh

# 2. Wait a few seconds
sleep 3

# 3. Reinstall
cd ~/focus-session-installer
bash install.sh

# 4. Verify
ps aux | grep watch_inactivity_simple | grep -v grep
cat ~/focus-session-status.txt
```

---

## Getting Help

If you're still stuck:

1. **Collect diagnostics**:
   ```bash
   echo "=== PROCESSES ===" && ps aux | grep watch_inactivity
   echo "=== LAUNCHCTL ===" && launchctl list | grep focus
   echo "=== RECENT LOGS ===" && tail -20 /tmp/watch_inactivity_simple.log
   echo "=== PLIST CHECK ===" && plutil -lint ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
   echo "=== STATUS ===" && cat ~/focus-session-status.txt
   ```

2. **Check GitHub Issues**: https://github.com/yourusername/focus-session-installer/issues

3. **Include in report**:
   - Output from diagnostics above
   - What you were trying to do
   - What error message you saw
   - Your macOS version: `sw_vers`

---

## Common Messages & What They Mean

| Message | Meaning | Action |
|---------|---------|--------|
| `Session start:` | New session began | ✓ Normal |
| `Session end:` | Session completed | ✓ Normal |
| `Session reset due to inactivity` | Idle > threshold | ✓ Normal (can adjust) |
| `Shortcut completed successfully` | Alert sent | ✓ Normal |
| `WARNING: Shortcut timed out` | Alert took too long | ⚠️ May need restart |
| `Lock command not available` | CGSession path missing | ⚠️ Use Shortcut lock feature |
| `Watcher already running` | Duplicate instance | ⚠️ See Issue 5 |
| `Triggering shortcut with input` | Alert being sent | ✓ Normal |

---

**Still need help?** Create an issue on GitHub with the diagnostic output above!
