#!/usr/bin/env zsh
"""
focus_session.sh - consolidated helper for Focus Session installer

Usage: focus_session.sh <command>

Commands (TOC):
  help                Show this help / table of contents
  active-session      Print the Active Session block (calls active_session.sh)
  open-log            Open the live log in TextEdit (calls open_focus_log.sh)
  rotate              Rotate the live log (calls rotate_focus_log.sh)
  to-csv              Convert live log to CSV (calls log_to_csv.sh)
  install-rotate     Install and load the daily rotate LaunchAgent
  uninstall-rotate   Unload and remove the rotate LaunchAgent

This script is a convenience wrapper so Shortcuts or users can call a single
file with subcommands. The original small focused scripts remain in the
installer directory and are still available individually.
"""

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

##########
# Helpers
##########
script_path() {
  # helper scripts now live in bin/
  echo "$BASE_DIR/bin/$1"
}

require_file() {
  if [[ ! -x "$1" ]]; then
    echo "Warning: $1 not found or not executable" >&2
  fi
}

##########
# Commands
##########
cmd_help() {
  cat <<'EOF'
Focus Session - consolidated helper

Usage: focus_session.sh <command>

Commands:
  help                Show this help / table of contents
  active-session      Print the Active Session block
  open-log            Open the live log in TextEdit
  rotate              Rotate the live log into ~/Library/Logs/focus-session
  to-csv              Convert the live log to today's CSV
  install-rotate      Install and load the daily rotate LaunchAgent
  uninstall-rotate    Unload and remove the rotate LaunchAgent

Examples:
  /bin/zsh ~/shortcuts-scripts/focus-session-installer/focus_session.sh open-log
  /bin/zsh ~/shortcuts-scripts/focus-session-installer/focus_session.sh active-session
EOF
}

cmd_active_session() {
  sh=$(script_path active_session.sh)
  if [[ -x "$sh" ]]; then
    /bin/zsh "$sh"
  else
    echo "active_session.sh not found; expected: $sh" >&2
    exit 1
  fi
}

cmd_open_log() {
  sh=$(script_path open_focus_log.sh)
  if [[ -x "$sh" ]]; then
    /bin/zsh "$sh"
  else
    echo "open_focus_log.sh not found; expected: $sh" >&2
    exit 1
  fi
}

cmd_rotate() {
  sh=$(script_path rotate_focus_log.sh)
  if [[ -x "$sh" ]]; then
    /bin/zsh "$sh"
  else
    echo "rotate_focus_log.sh not found; expected: $sh" >&2
    exit 1
  fi
}

cmd_to_csv() {
  sh=$(script_path log_to_csv.sh)
  if [[ -x "$sh" ]]; then
    /bin/zsh "$sh"
  else
    echo "log_to_csv.sh not found; expected: $sh" >&2
    exit 1
  fi
}

cmd_install_rotate() {
  plist_src=$(script_path com.user.rotate_focus_log.plist)
  plist_dst="$HOME/Library/LaunchAgents/com.user.rotate_focus_log.plist"
  if [[ ! -f "$plist_src" ]]; then
    echo "Rotate plist not found: $plist_src" >&2
    exit 1
  fi
  mkdir -p "$HOME/Library/LaunchAgents"
  cp -f "$plist_src" "$plist_dst"
  launchctl load -w "$plist_dst"
  echo "Installed and loaded $plist_dst"
}

cmd_uninstall_rotate() {
  plist_dst="$HOME/Library/LaunchAgents/com.user.rotate_focus_log.plist"
  if [[ -f "$plist_dst" ]]; then
    launchctl unload "$plist_dst" || true
    rm -f "$plist_dst"
    echo "Unloaded and removed $plist_dst"
  else
    echo "Rotate LaunchAgent not installed: $plist_dst"
  fi
}

##########
# Dispatch
##########
if (( $# == 0 )); then
  cmd_help
  exit 0
fi

case "$1" in
  help|-h|--help)
    cmd_help
    ;;
  active-session|active_session)
    cmd_active_session
    ;;
  open-log|open_log)
    cmd_open_log
    ;;
  rotate)
    cmd_rotate
    ;;
  to-csv|tocsv)
    cmd_to_csv
    ;;
  install-rotate|install_rotate)
    cmd_install_rotate
    ;;
  uninstall-rotate|uninstall_rotate)
    cmd_uninstall_rotate
    ;;
  *)
    echo "Unknown command: $1" >&2
    cmd_help
    exit 2
    ;;
esac
