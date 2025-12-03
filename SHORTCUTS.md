# Focus Session Watcher - Shortcuts Setup Guide

This tool uses **3 public macOS Shortcuts** to handle notifications and screen management. They're all available via iCloud links.

---

## 📱 Required Shortcuts

### 1. [focus-session--script_macos](https://www.icloud.com/shortcuts/1ec30ee610c14db68af3621971000993)
**Purpose**: Main integration point for the watcher script  
**What it does**:
- Receives "start" or "end" messages from the watcher
- Handles session logic and callbacks
- Coordinates with other shortcuts

**Installation**: Click the link above → "Add Shortcut" → Done

**Manual Alternative** (if link doesn't work):
```bash
# Use the included shortcut file
open Shortcuts/
# Then File → Open → focus-session--script_macos.shortcut
```

---

### 2. [focus-session--script-alert_macos](https://www.icloud.com/shortcuts/55c84ca1e2494e5598dd1201f83c03b2)
**Purpose**: Alerts and screen management  
**What it does**:
- Shows notifications when sessions start/end
- Locks the screen after session completion (optional)
- Plays notification sounds
- Displays countdown timer

**Installation**: Click the link above → "Add Shortcut" → Done

**Manual Alternative**:
```bash
open Shortcuts/
# Then File → Open → focus-session--script-alert_macos.shortcut
```

---

### 3. [focus-session--script-status_macos](https://www.icloud.com/shortcuts/fa0f9e41125b499b8fe74705109b0d6d) (Optional)
**Purpose**: View current session status  
**What it does**:
- Displays session countdown in a popup
- Shows time elapsed and time remaining
- Quick status check without opening terminal

**Installation**: Click the link above → "Add Shortcut" → Done

**Manual Alternative**:
```bash
open Shortcuts/
# Then File → Open → focus-session--script_mac--inactivity-status.shortcut
```

---

## 🚀 Quick Setup

### One-Click Installation

1. Open this guide and click each shortcut link above
2. Click "Add Shortcut" for each one
3. Done! All 3 shortcuts are now in your library

### Manual Installation (Offline or Link Issues)

```bash
# Navigate to Shortcuts folder
cd ~/focus-session-installer/Shortcuts

# Open Shortcuts app and manually import each file:
# File → Open → Select .shortcut file → Add

# Or use this helper if installed:
bash ~/Library/Application\ Support/focus-session/installer/bin/setup_shortcuts.sh
```

---

## 🔧 Verify Shortcuts Are Imported

After importing, verify they're available:

```bash
# Check if shortcuts are recognized by the system
shortcuts list 2>/dev/null | grep "focus-session"

# Should show:
# focus-session--script_macos
# focus-session--script-alert_macos  
# focus-session--script-status_macos
```

If the shortcuts aren't showing, try:

1. **Open Shortcuts app** and verify they appear in your library
2. **Restart Shortcuts**: Close and reopen the app
3. **Restart watcher**: `pkill -f watch_inactivity_simple`
4. **Check logs**: `tail -20 /tmp/watch_inactivity_simple.log | grep -i shortcut`

---

## 📋 Shortcut Details & Settings

### Privacy & Security Configuration

All shortcuts are configured with:
- ✅ **Ask When Run**: Disabled (required for automation)
- ✅ **Require Approval**: No
- ✅ **Share Over Cellular**: Disabled
- ✅ **Run in Background**: Enabled
- ✅ **Security**: Local files only, no network access

### Customization Options

#### Alerts (in focus-session--script-alert_macos)
- Notification sound: ✅ Enabled
- Notification style: Alert (banner)
- Auto-lock screen: ✅ Enabled (can be toggled in shortcut settings)

#### Status Check (in focus-session--script-status_macos)
- Display type: Popup alert
- Show countdown: ✅ Yes
- Refresh interval: Reads current file (live)

### Permissions Required

Your shortcuts need:
- ✅ **Notification permission** (auto-granted on import)
- ✅ **Read/write to home directory** (auto-granted)
- ✅ **Shortcut runner permission** (user enables once in System Preferences)

**No special macOS permissions required!** No Full Disk Access, Accessibility permission, or other elevated privileges needed.

---

### focus-session--script_macos
```
Input: "start" or "end" message
├─ Parse input message
├─ Track session timing
├─ Call appropriate handlers
├─ Call focus-session--script-alert_macos for notifications
└─ Return success/failure
```

### focus-session--script-alert_macos  
```
Input: Session event (start/end) with details
├─ Show notification banner
├─ Play notification sound
├─ Update status display
├─ (Optional) Lock screen
└─ Log event completion
```

### focus-session--script_mac--inactivity-status
```
Input: None (triggered on-demand)
├─ Read session status
├─ Calculate time remaining
├─ Display popup with countdown
└─ Allow quick session info access
```

---

## 🔐 Privacy & Security

### What We Collect
- ✅ **Nothing** - Zero data collection
- ✅ No analytics or tracking
- ✅ No telemetry or crash reporting
- ✅ No third-party integrations

### What Shortcuts Can Access
- Read/write your focus session logs (local only)
- Display notifications (standard macOS feature)
- Lock your screen (you requested this)
- Read system idle time (public HID info)

### What Shortcuts CANNOT Access
- ❌ Your files outside focus-session directories
- ❌ Camera, microphone, or location
- ❌ Contacts, calendar, or messages
- ❌ Network or internet
- ❌ Other apps' data

### Transparency & Auditing
These shortcuts:
- ✅ Are completely visible and auditable in the Shortcuts app
- ✅ Have descriptive comments linking to GitHub for full transparency
- ✅ Are open-source (MIT License) - you can inspect the logic
- ✅ Run locally on your machine only
- ✅ Don't communicate with external servers

**View the shortcuts** by opening them in Shortcuts app to see exactly what they do!

---

---

## ⚠️ Troubleshooting

### Shortcuts Not Running

**Error**: "Shortcut could not find the specified shortcut"

**Solution**:
1. Open Shortcuts app
2. Verify all 3 shortcuts appear in your library
3. Verify they're named exactly:
   - `focus-session--script_macos`
   - `focus-session--script-alert_macos`
   - `focus-session--script_mac--inactivity-status`
4. Restart the watcher: `pkill -f watch_inactivity_simple`

---

### "Shortcuts is not enabled for Running scripts"

**Solution**:
1. System Preferences → Security & Privacy
2. Look for "Shortcuts" option
3. Enable "Allow Running scripts"
4. Restart watcher

---

### Shortcuts Work but No Alerts

**Solution**:
1. Check notification settings: System Preferences → Notifications → Shortcuts
2. Ensure "Alerts" is enabled, not "Badges" or "Sounds only"
3. Check your Focus mode - might be suppressing notifications
4. Verify `focus-session--script-alert_macos` is in your Shortcuts library

---

### Getting Link Errors (iCloud Shortcuts not accessible)

If you can't access the iCloud Shortcuts links:

1. Verify you're signed into iCloud on your Mac
2. Check internet connection
3. Try refreshing the iCloud Shortcuts link
4. Use **Manual Installation** (see above)

---

## 🎯 Next Steps

After importing shortcuts:

1. Verify installation: `bash ~/focus-session-installer/verify-package.sh`
2. Check watcher status: `cat ~/focus-session-status.txt`
3. View logs: `tail -20 /tmp/watch_inactivity_simple.log`
4. Read full guide: See `USAGE.md`

---

## 📚 More Info

- **README.md** - Overview and quick start
- **USAGE.md** - Detailed usage examples
- **TROUBLESHOOTING.md** - Common issues and fixes
- **GitHub** - https://github.com/dreisdesign/focus-session

---

**All shortcuts created by Daniel Reis**  
**Open source under MIT License**  
**Comments in each shortcut link to GitHub repository for full transparency**
