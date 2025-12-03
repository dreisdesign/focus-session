#!/bin/bash
# Focus Session Watcher - Installation Script
# This script copies all files to ~/Library/Application Support and sets up LaunchAgent

set -e  # Exit on any error

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Focus Session Watcher - Installation              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Get the directory this script is in
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/Library/Application Support/focus-session/installer"
LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
LOGS_DIR="$HOME/Library/Logs/focus-session"

echo "📁 Installation paths:"
echo "   Source: $SCRIPT_DIR"
echo "   Target: $INSTALL_DIR"
echo ""

# Create directories
echo "📂 Creating directories..."
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/Shortcuts"
mkdir -p "$LAUNCHAGENTS_DIR"
mkdir -p "$LOGS_DIR"
echo "   ✓ Directories created"
echo ""

# Copy main scripts
echo "📋 Copying scripts..."
cp "$SCRIPT_DIR/watch_inactivity_simple.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/focus_session.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/watch_inactivity_simple.sh"
chmod +x "$INSTALL_DIR/focus_session.sh"
echo "   ✓ Main scripts copied"

# Copy helper scripts
echo "📋 Copying helper scripts..."
cp "$SCRIPT_DIR/bin"/* "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin"/*.sh
echo "   ✓ Helper scripts copied"

# Copy plist files
echo "📋 Copying LaunchAgent plists..."
cp "$SCRIPT_DIR/com.user.watch_inactivity_simple.plist" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/com.user.rotate_focus_log.plist" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/com.user.rotate_focus_log.plist" "$INSTALL_DIR/bin/"
echo "   ✓ Plist files copied"

# Copy Shortcut
echo "📋 Copying Shortcut file..."
if [ -d "$SCRIPT_DIR/Shortcuts" ]; then
    cp "$SCRIPT_DIR/Shortcuts"/*.shortcut "$INSTALL_DIR/Shortcuts/" 2>/dev/null || true
    echo "   ✓ Shortcut file copied"
fi
echo ""

# Make plist files writable
echo "🔐 Setting file permissions..."
chmod 644 "$INSTALL_DIR"/*.plist
chmod 644 "$INSTALL_DIR/bin"/*.plist
echo "   ✓ Permissions set"
echo ""

# Install LaunchAgent
echo "⚙️  Installing LaunchAgent..."
cp "$INSTALL_DIR/com.user.watch_inactivity_simple.plist" "$LAUNCHAGENTS_DIR/"
chmod 644 "$LAUNCHAGENTS_DIR/com.user.watch_inactivity_simple.plist"
launchctl load "$LAUNCHAGENTS_DIR/com.user.watch_inactivity_simple.plist" 2>/dev/null || true
echo "   ✓ LaunchAgent installed and loaded"
echo ""

# Wait a moment for service to start
sleep 2

# Verify installation
echo "✅ Verifying installation..."
if ps aux | grep watch_inactivity_simple.sh | grep -v grep > /dev/null 2>&1; then
    echo "   ✓ Watcher process is running!"
    PID=$(pgrep -f watch_inactivity_simple.sh)
    echo "   Process ID: $PID"
else
    echo "   ⚠️  Watcher not yet running (may start in a few seconds)"
fi
echo ""

# Check status file
if [ -f "$HOME/focus-session-status.txt" ]; then
    STATUS=$(cat "$HOME/focus-session-status.txt")
    echo "   ✓ Status file created: $STATUS"
else
    echo "   ⏳ Status file not yet created (will appear shortly)"
fi
echo ""

# Check log file
if [ -f "/tmp/watch_inactivity_simple.log" ]; then
    LINES=$(wc -l < /tmp/watch_inactivity_simple.log)
    echo "   ✓ Log file created ($LINES lines)"
else
    echo "   ⏳ Log file not yet created (will appear shortly)"
fi
echo ""

# Offer to open Shortcuts app
echo "🎯 Next step: Import the Shortcut"
echo ""
echo "The Shortcut file is located at:"
echo "   $INSTALL_DIR/Shortcuts/script_mac--inactivity_shared.shortcut"
echo ""
echo "To import:"
echo "   1. Open the Shortcuts app"
echo "   2. Drag the .shortcut file into Shortcuts"
echo "   3. Or use: File → Open → select the .shortcut file"
echo "   4. Click 'Add' when prompted"
echo ""

read -p "Would you like to open Shortcuts now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open -a "Shortcuts"
    echo "   ✓ Opening Shortcuts app..."
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 Installation Complete! ✨                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📖 Quick start commands:"
echo ""
echo "   Check status:"
echo "   cat ~/focus-session-status.txt"
echo ""
echo "   View active session:"
echo "   bash ~/Library/Application\ Support/focus-session/installer/focus_session.sh active-session"
echo ""
echo "   View live log:"
echo "   tail -f /tmp/watch_inactivity_simple.log"
echo ""
echo "   Restart watcher:"
echo "   bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh"
echo ""
echo "📚 Learn more: See README.md and USAGE.md"
echo ""
