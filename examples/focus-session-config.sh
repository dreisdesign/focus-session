#!/bin/bash
# Example: How to customize Focus Session configuration
# Copy this file and modify to suit your needs

# ============================================
# SESSION DURATION
# ============================================
# Default is 1500 seconds (25 minutes - Pomodoro)
# Change SESSION_SECONDS in watch_inactivity_simple.sh

# For 10-second sessions (testing):
# SESSION_SECONDS=10

# For 5-minute sessions:
# SESSION_SECONDS=300

# For 45-minute sessions:
# SESSION_SECONDS=2700


# ============================================
# IDLE THRESHOLD
# ============================================
# Default is 120 seconds (2 minutes)
# If idle >= this value, session resets
# Change IDLE_THRESHOLD in watch_inactivity_simple.sh

# For 20-second idle detection (testing):
# IDLE_THRESHOLD=20

# For 5-minute idle detection:
# IDLE_THRESHOLD=300


# ============================================
# QUICK EXAMPLE: Testing Setup
# ============================================
# Temporarily set shorter durations for testing:

export SESSION_SECONDS=10    # 10-second sessions
export IDLE_THRESHOLD=20     # 20-second idle threshold

# Then start the watcher:
# bash ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh


# ============================================
# PERMANENT: Edit the scripts
# ============================================
# 1. Edit main watcher script:
#    nano ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh
#
#    Find line ~46:
#    SESSION_SECONDS=${SESSION_SECONDS:-1500}
#    Change 1500 to your value
#
#    Find line ~10:
#    IDLE_THRESHOLD=120
#    Change 120 to your value

# 2. Update helper script (must match):
#    nano ~/Library/Application\ Support/focus-session/installer/bin/active_session.sh
#
#    Find line ~10:
#    SESSION_SECONDS=${SESSION_SECONDS:-1500}
#    Change to same value as main script

# 3. Restart watcher:
#    bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh


# ============================================
# COMMON CONFIGURATIONS
# ============================================

# Config 1: Ultra-short for testing
# SESSION_SECONDS=10
# IDLE_THRESHOLD=20

# Config 2: Quick breaks (15 min)
# SESSION_SECONDS=900
# IDLE_THRESHOLD=120

# Config 3: Standard Pomodoro (25 min)
# SESSION_SECONDS=1500
# IDLE_THRESHOLD=120

# Config 4: Deep work (45 min)
# SESSION_SECONDS=2700
# IDLE_THRESHOLD=300

# Config 5: Lenient idle (5 min before reset)
# SESSION_SECONDS=1500
# IDLE_THRESHOLD=300


# ============================================
# HOW TO APPLY CUSTOM CONFIG
# ============================================

# Step 1: Decide on your values
SESSION_SECONDS=1500  # Change this
IDLE_THRESHOLD=120    # Change this

# Step 2: Edit the main script
nano ~/Library/Application\ Support/focus-session/installer/watch_inactivity_simple.sh
# Update line ~46 and ~10 with your values

# Step 3: Edit the helper script
nano ~/Library/Application\ Support/focus-session/installer/bin/active_session.sh
# Update line ~10 to match SESSION_SECONDS

# Step 4: Restart the watcher
bash ~/Library/Application\ Support/focus-session/installer/restart_focus_session.sh

# Step 5: Verify
cat ~/focus-session-status.txt
