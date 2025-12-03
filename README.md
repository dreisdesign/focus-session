# Focus Session Watcher

A lightweight, minimalist macOS automation tool that monitors your activity and manages 25-minute focus sessions (Pomodoro technique). Automatically sends notifications at session end and optionally locks your screen.

**Perfect for**: Boosting productivity, tracking focus time, and maintaining healthy work breaks.

**📚 Full Documentation**: [README](README.md) • [Usage Guide](USAGE.md) • [Shortcuts Setup](SHORTCUTS.md) • [Troubleshooting](TROUBLESHOOTING.md) • [Security Audit](SECURITY.md)

---

## ✨ Features

- 🎯 **Automatic Focus Sessions** - Starts 25-minute sessions when you're active
- ⏱️ **Session Countdown** - Real-time MM:SS status in a file you can read
- 🔔 **Smart Notifications** - Alerts at session start and completion via macOS Shortcuts
- 🔒 **Auto-Lock** - Optionally locks your screen after sessions
- 📊 **Data Logging** - Daily CSV exports for productivity tracking
- 🧠 **Idle Detection** - Resets sessions when inactive (120 seconds default)
- 💾 **Lightweight** - ~1-2 MB memory, negligible CPU/battery impact
- 🔄 **Auto-Rotate** - Daily log archival (optional)

---

## 📋 Requirements

- **macOS** 10.15+ (Catalina or later)
- **Shortcuts app** (built-in on macOS)
- **zsh** (default shell on macOS 10.15+)
- **iCloud Shortcuts access** - Required to import public shortcuts for alerts
- **No external dependencies** - Uses only built-in macOS tools

---

## 🚀 Quick Start

### 1. Clone or Download

**Option A - GitHub**:
```bash
git clone https://github.com/yourusername/focus-session-installer.git
cd focus-session-installer
```

**Option B - ZIP Download**:
```bash
# Download the ZIP file, then:
unzip focus-session-installer.zip
cd focus-session-installer
```

### 2. Install

```bash
chmod +x install.sh
./install.sh
```

This will:
- Copy scripts to `~/Library/Application Support/focus-session/`
- Install LaunchAgent for automatic startup
- Make scripts executable

### 3. Import Shortcuts

You need to import 3 shortcuts. Click the links below and click "Add Shortcut" in each:

**Required:**
1. **[focus-session--script_macos](https://www.icloud.com/shortcuts/1ec30ee610c14db68af3621971000993)** - Main watcher integration
2. **[focus-session--script-alert_macos](https://www.icloud.com/shortcuts/55c84ca1e2494e5598dd1201f83c03b2)** - Start/end alerts and screen lock

**Optional (for log status):**
3. **[focus-session--script-status_macos](https://www.icloud.com/shortcuts/fa0f9e41125b499b8fe74705109b0d6d)** - View session status

**Manual Import Alternative:**
If the links don't work, use the `.shortcut` files in the `Shortcuts/` folder:
1. Open macOS Shortcuts app
2. File → Open → select the `.shortcut` file
3. Click "Add" when prompted

### 4. Verify Installation

```bash
# Check if watcher is running
ps aux | grep watch_inactivity_simple | grep -v grep

# View current session status
cat ~/focus-session-status.txt
# Output: MM:SS format (e.g., "25:00", "12:34") or "Inactive"

# View live log
tail -20 /tmp/watch_inactivity_simple.log
```

---

## 📖 Usage

### Check Current Session

```bash
# Simple countdown (MM:SS format)
cat ~/focus-session-status.txt

# Detailed session info (start time, end time, time remaining)
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh active-session

# Or use the helper directly
bash ~/Library/Application\ Support/focus-session/installer/bin/active_session.sh
```

### View Logs

```bash
# Live log (real-time updates)
tail -f /tmp/watch_inactivity_simple.log

# Last 20 entries
tail -20 /tmp/watch_inactivity_simple.log

# Open in TextEdit
bash ~/Library/Application\ Support/focus-session/installer/bin/open_focus_log.sh
```

### Manage Sessions

```bash
# Restart the watcher (apply any changes)
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# Manually rotate today's log to archives
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh rotate

# Convert log to CSV for analysis
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh to-csv

# Enable daily log rotation (if not already enabled)
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh install-rotate

# Disable daily log rotation
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh uninstall-rotate
```

---

## ⚙️ Configuration

### Change Session Duration

Edit the main script:
```bash
nano ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh
```

Find this line (~46):
```bash
SESSION_SECONDS=${SESSION_SECONDS:-1500}
```

Change `1500` to your preferred duration in seconds:
- `10` - 10 seconds (testing)
- `60` - 1 minute
- `300` - 5 minutes
- `600` - 10 minutes
- `1500` - 25 minutes (default Pomodoro)
- `2700` - 45 minutes

**Also update** the helper script to match:
```bash
nano ~/Library/Application\ Support/focus-session/installer/bin/active_session.sh
```

Same line, same value must be synchronized.

### Change Idle Threshold

In `watch_inactivity_simple.sh`, find line ~10:
```bash
IDLE_THRESHOLD=120
```

Change `120` to your preferred idle time in seconds:
- `20` - 20 seconds (testing)
- `60` - 1 minute
- `120` - 2 minutes (default)
- `300` - 5 minutes

### Environment Variables

You can also set these temporarily without editing files:

```bash
# Test with 10-second sessions and 20-second idle threshold
export SESSION_SECONDS=10
export IDLE_THRESHOLD=20
bash ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh
```

---

## 📊 Data & Analytics

### Where Logs Are Stored

| Location | Purpose | Format |
|----------|---------|--------|
| `~/focus-session-status.txt` | Current session countdown | `MM:SS` |
| `/tmp/watch_inactivity_simple.log` | Live log (24 hours) | Human-readable |
| `/tmp/watch_inactivity_state.json` | Machine state | JSON |
| `~/Library/Logs/focus-session/` | Archives (persistent) | `.csv.gz` |

### Export Data

```bash
# View today's CSV
cat ~/Library/Logs/focus-session/focus-session-$(date +%F).csv

# Combine all sessions into one file
cat ~/Library/Logs/focus-session/focus-session-*.csv > all-sessions.csv

# Count completed sessions today
awk -F, 'NR>1 && $9==1 {count++} END {print count}' \
  ~/Library/Logs/focus-session/focus-session-$(date +%F).csv

# Calculate total focus time (in hours)
awk -F, 'NR>1 && $9==1 {total+=$8} END {print total/3600}' \
  ~/Library/Logs/focus-session/focus-session-$(date +%F).csv
```

### CSV Format

Each daily CSV contains:
- `session` - Session number
- `start_epoch` - Unix timestamp (start)
- `start_iso` - ISO 8601 format
- `start_human` - Readable format (H:MMAM/PM)
- `end_epoch` - Unix timestamp (end)
- `end_iso` - ISO 8601 format
- `end_human` - Readable format
- `duration_sec` - Session length in seconds
- `completed` - 1 if complete, 0 if incomplete

---

## 🔒 Privacy & Security

### Zero Data Collection
- ✅ **No tracking or analytics** - Your activity data never leaves your machine
- ✅ **No telemetry** - We don't monitor usage patterns
- ✅ **No cloud sync** - Everything stays local
- ✅ **No third-party integrations** - Only uses built-in macOS tools
- ✅ **Open source** - Full transparency, MIT License

### Minimal Permissions Required
- ✅ Notification permission (standard, auto-granted)
- ✅ Read/write to your home directory (for logs)
- ❌ No Full Disk Access
- ❌ No Accessibility permission
- ❌ No network access

### Complete Audit Trail
- 📖 See [SECURITY.md](SECURITY.md) for full security audit
- 📋 See [SHORTCUTS.md](SHORTCUTS.md) for shortcut details and permissions
- 🔍 Source code is visible and auditable on GitHub

**Your focus sessions are private, secure, and under your complete control.**

---

### Watcher Not Starting

```bash
# Check if LaunchAgent is loaded
launchctl list | grep watch_inactivity

# If not loaded, load it manually
launchctl load ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist

# Check for errors
cat /tmp/watch_inactivity_simple.launch.err.log
```

### Session Not Starting After Activity

```bash
# Check idle detection is working
ioreg -c IOHIDSystem | grep HIDIdleTime

# Low value = active, high value = idle

# Check current state
cat /tmp/watch_inactivity_state.json
```

### Shortcut Not Triggering

```bash
# Test manually
shortcuts run "script_mac--inactivity_shared" --input "start"
shortcuts run "script_mac--inactivity_shared" --input "end"

# If error: check Shortcuts has permission
# System Settings → Privacy & Security → Automation → Shortcuts
```

### Duplicate Watcher Instances

```bash
# Remove stale locks
rm -rf /tmp/watch_inactivity_simple.lock /tmp/watch_inactivity_simple.pid

# Restart
launchctl unload ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
launchctl load ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
```

### See Full Troubleshooting

See `TROUBLESHOOTING.md` for 15+ common issues and solutions.

---

## 🗑️ Uninstall

```bash
# Option 1: Use the uninstall script (if available)
bash uninstall.sh

# Option 2: Manual uninstall
launchctl unload ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
rm -f ~/Library/LaunchAgents/com.user.watch_inactivity_simple.plist
rm -rf ~/Library/Application\ Support/focus-session/
rm -f ~/focus-session-status.txt
```

---

## 📂 What's Included

```
focus-session-installer/
├── README.md                          # This file
├── TROUBLESHOOTING.md                 # Detailed troubleshooting guide
├── USAGE.md                           # Comprehensive usage guide
├── LICENSE                            # MIT License
├── install.sh                         # Installation script
├── uninstall.sh                       # Uninstallation script
├── watch_inactivity_simple.sh         # Main watcher script
├── focus_session.sh                   # Unified wrapper/CLI
├── com.user.watch_inactivity_simple.plist
├── com.user.rotate_focus_log.plist
├── bin/
│   ├── active_session.sh              # Show active session status
│   ├── open_focus_log.sh              # Open log in TextEdit
│   ├── rotate_focus_log.sh            # Rotate logs to archives
│   ├── log_to_csv.sh                  # Convert logs to CSV
│   └── com.user.rotate_focus_log.plist
├── Shortcuts/
│   └── script_mac--inactivity_shared.shortcut
├── .github/
│   └── workflows/                     # (Optional) CI/CD workflows
└── examples/
    └── focus-session-config.sh        # Example config changes
```

---

## 🔄 How It Works

**Focus Session Watcher** polls your system every 2 seconds:

1. Checks idle time via `ioreg` (HID device)
2. If idle ≥ 120s: Reset session
3. If active: Start 25-min session (if not already running)
4. Trigger Shortcut with "start" input
5. After 25 min: Trigger Shortcut with "end" input
6. Lock screen and reset
7. Write status to `~/focus-session-status.txt`
8. Log all events to `/tmp/watch_inactivity_simple.log`

**Daily Log Rotator** (runs at 23:59):

1. Convert log to CSV
2. Compress log with gzip
3. Move to `~/Library/Logs/focus-session/`
4. Create fresh log for tomorrow

---

## 📝 License

MIT License - See `LICENSE` file for details.

This project was created for personal productivity. Feel free to use, modify, and distribute!

---

## 🤝 Contributing

Want to improve this? Feel free to:
- Report bugs via GitHub Issues
- Submit improvements via Pull Requests
- Share your productivity tips in Discussions

---

## 📞 Support

Having issues? Check:

1. **`TROUBLESHOOTING.md`** - 15+ common issues
2. **`USAGE.md`** - Detailed usage guide
3. **GitHub Issues** - Search for similar problems
4. **Shell script logs** - `/tmp/watch_inactivity_simple.log`

---

## 🎯 Quick Reference

```bash
# Check status
cat ~/focus-session-status.txt

# View active session
bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh active-session

# View live log
tail -f /tmp/watch_inactivity_simple.log

# Restart watcher
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# Uninstall
bash uninstall.sh
```

---

**Made with ❤️ for focused developers and creatives**
