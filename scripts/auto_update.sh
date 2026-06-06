#!/bin/bash

# ─────────────────────────────────────────
# Task #1: Auto System Updater
# Author: Rex | DevOps Toolkit
# Runs: Every day at 8:00am via cron
# ─────────────────────────────────────────

LOG_FILE=~/devops-toolkit/logs/updates.log
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] Starting system update..." >> "$LOG_FILE"

brew update >> "$LOG_FILE" 2>&1
echo "[$DATE] Homebrew updated" >> "$LOG_FILE"

brew upgrade >> "$LOG_FILE" 2>&1
echo "[$DATE] Packages upgraded" >> "$LOG_FILE"

brew cleanup >> "$LOG_FILE" 2>&1
echo "[$DATE] ✅ Cleanup done & update complete!" >> "$LOG_FILE"
echo "─────────────────────────────" >> "$LOG_FILE"
