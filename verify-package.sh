#!/bin/bash
# Package Verification Script - Verify all required files are present

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Focus Session Installer - Package Verification         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MISSING=0
FOUND=0

check_file() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        echo "  ✓ $desc"
        ((FOUND++))
    else
        echo "  ✗ $file (MISSING)"
        ((MISSING++))
    fi
}

check_dir() {
    local dir=$1
    local desc=$2
    if [ -d "$dir" ]; then
        echo "  ✓ $desc (directory)"
        ((FOUND++))
    else
        echo "  ✗ $dir (MISSING)"
        ((MISSING++))
    fi
}

echo "📋 Checking Core Files..."
check_file "$PACKAGE_DIR/install.sh" "Installation script"
check_file "$PACKAGE_DIR/uninstall.sh" "Uninstallation script"
check_file "$PACKAGE_DIR/watch_inactivity_simple.sh" "Main watcher script"
check_file "$PACKAGE_DIR/focus_session.sh" "Unified wrapper script"
echo ""

echo "📋 Checking Documentation..."
check_file "$PACKAGE_DIR/README.md" "README"
check_file "$PACKAGE_DIR/USAGE.md" "Usage guide"
check_file "$PACKAGE_DIR/TROUBLESHOOTING.md" "Troubleshooting guide"
check_file "$PACKAGE_DIR/CONTRIBUTING.md" "Contributing guide"
check_file "$PACKAGE_DIR/CHANGELOG.md" "Changelog"
check_file "$PACKAGE_DIR/LICENSE" "MIT License"
echo ""

echo "📋 Checking LaunchAgent Files..."
check_file "$PACKAGE_DIR/com.user.watch_inactivity_simple.plist" "Main LaunchAgent plist"
check_file "$PACKAGE_DIR/com.user.rotate_focus_log.plist" "Log rotator plist"
echo ""

echo "📋 Checking Helper Scripts..."
check_dir "$PACKAGE_DIR/bin" "Helper scripts directory"
check_file "$PACKAGE_DIR/bin/active_session.sh" "Active session helper"
check_file "$PACKAGE_DIR/bin/open_focus_log.sh" "Open log helper"
check_file "$PACKAGE_DIR/bin/rotate_focus_log.sh" "Log rotation script"
check_file "$PACKAGE_DIR/bin/log_to_csv.sh" "CSV conversion script"
echo ""

echo "📋 Checking Shortcuts..."
check_dir "$PACKAGE_DIR/Shortcuts" "Shortcuts directory"
check_file "$PACKAGE_DIR/Shortcuts/script_mac--inactivity_shared.shortcut" "Focus session shortcut"
echo ""

echo "📋 Checking Examples..."
check_dir "$PACKAGE_DIR/examples" "Examples directory"
check_file "$PACKAGE_DIR/examples/focus-session-config.sh" "Configuration example"
echo ""

echo "📋 Checking Git Configuration..."
check_file "$PACKAGE_DIR/.gitignore" ".gitignore file"
check_dir "$PACKAGE_DIR/.github" "GitHub metadata directory"
echo ""

# Verify script permissions
echo "📋 Checking Script Permissions..."
for script in "$PACKAGE_DIR"/*.sh "$PACKAGE_DIR/bin"/*.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "  ✓ $script is executable"
            ((FOUND++))
        else
            echo "  ✗ $script is NOT executable"
            ((MISSING++))
        fi
    fi
done
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════╗"
if [ $MISSING -eq 0 ]; then
    echo "║              ✓ Package Complete!                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Summary: All $FOUND files present and scripts executable"
    echo ""
    echo "Package is ready for distribution!"
    echo ""
    echo "Next steps:"
    echo "  1. Test installation: bash install.sh"
    echo "  2. Verify functionality: cat ~/focus-session-status.txt"
    echo "  3. Create ZIP: zip -r focus-session-installer.zip focus-session-installer/"
    echo "  4. Upload to GitHub"
    echo ""
    exit 0
else
    echo "║         ✗ Package Incomplete                              ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Summary: $FOUND files found, $MISSING missing or not executable"
    echo ""
    exit 1
fi
