#!/bin/bash
# Focus Session Watcher - Uninstallation Script

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Focus Session Watcher - Uninstallation            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

read -p "Are you sure you want to uninstall Focus Session Watcher? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "🛑 Uninstalling Focus Session Watcher..."
echo ""

LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
INSTALL_DIR="$HOME/Library/Application Support/focus-session"

# Unload LaunchAgent
echo "⏹️  Stopping watcher service..."
if [ -f "$LAUNCHAGENTS_DIR/com.user.watch_inactivity_simple.plist" ]; then
    launchctl unload "$LAUNCHAGENTS_DIR/com.user.watch_inactivity_simple.plist" 2>/dev/null || true
    sleep 1
    echo "   ✓ LaunchAgent unloaded"
fi

# Unload rotation service if installed
echo "⏹️  Stopping log rotator service (if installed)..."
if [ -f "$LAUNCHAGENTS_DIR/com.user.rotate_focus_log.plist" ]; then
    launchctl unload "$LAUNCHAGENTS_DIR/com.user.rotate_focus_log.plist" 2>/dev/null || true
    echo "   ✓ Log rotator unloaded"
fi

# Remove plist files
echo "🗑️  Removing LaunchAgent files..."
rm -f "$LAUNCHAGENTS_DIR/com.user.watch_inactivity_simple.plist"
rm -f "$LAUNCHAGENTS_DIR/com.user.rotate_focus_log.plist"
echo "   ✓ LaunchAgent files removed"

# Remove application support
echo "🗑️  Removing application files..."
rm -rf "$INSTALL_DIR"
echo "   ✓ Application files removed"

# Remove status file
echo "🗑️  Removing status file..."
rm -f "$HOME/focus-session-status.txt"
echo "   ✓ Status file removed"

# Remove temp files
echo "🗑️  Removing temporary files..."
rm -f /tmp/watch_inactivity_simple.log
rm -f /tmp/watch_inactivity_simple.pid
rm -rf /tmp/watch_inactivity_simple.lock
rm -f /tmp/watch_inactivity_state.json
rm -f /tmp/watch_inactivity_simple.launch.out.log
rm -f /tmp/watch_inactivity_simple.launch.err.log
echo "   ✓ Temporary files removed"

echo ""
echo "📝 Note: Archive logs are preserved at:"
echo "   $HOME/Library/Logs/focus-session/"
echo ""
echo "   Delete manually if you want to remove all data:"
echo "   rm -rf ~/Library/Logs/focus-session/"
echo ""
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║               Uninstallation Complete ✓                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
