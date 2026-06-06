#!/bin/bash

# ─────────────────────────────────────────
# Task #3: Log Rotation & Cleanup
# Author: Rex | DevOps Toolkit
# Runs: Every Sunday at 3am via cron
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

LOG_DIR=~/devops-toolkit/logs
ROTATION_LOG=$LOG_DIR/rotation.log
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "─────────────────────────────" >> "$ROTATION_LOG"
echo "[$DATE] Starting log rotation..." >> "$ROTATION_LOG"

# ─────────────────────────────────────────
# Step 1: Compress logs larger than 1MB
# ─────────────────────────────────────────
echo "[$DATE] Checking for large logs to compress..." >> "$ROTATION_LOG"

for LOG_FILE in $LOG_DIR/*.log; do
    # Skip the rotation log itself
    if [[ "$LOG_FILE" == "$ROTATION_LOG" ]]; then
        continue
    fi

    FILE_SIZE=$(du -k "$LOG_FILE" | cut -f1)

    if [ "$FILE_SIZE" -gt 1024 ]; then
        gzip "$LOG_FILE"
        echo "[$DATE] 🗜️  Compressed: $(basename $LOG_FILE) (${FILE_SIZE}KB)" >> "$ROTATION_LOG"
    else
        echo "[$DATE] ✅ OK: $(basename $LOG_FILE) (${FILE_SIZE}KB) — no compression needed" >> "$ROTATION_LOG"
    fi
done

# ─────────────────────────────────────────
# Step 2: Delete compressed logs older than 14 days
# ─────────────────────────────────────────
echo "[$DATE] Cleaning up old compressed logs..." >> "$ROTATION_LOG"

DELETED=0
find $LOG_DIR -name "*.gz" -mtime +14 -print | while read OLD_LOG; do
    rm "$OLD_LOG"
    echo "[$DATE] 🗑️  Deleted: $(basename $OLD_LOG)" >> "$ROTATION_LOG"
    DELETED=$((DELETED + 1))
done

# ─────────────────────────────────────────
# Step 3: Clean macOS system logs
# ─────────────────────────────────────────
echo "[$DATE] Cleaning macOS system logs..." >> "$ROTATION_LOG"

# Clear old system logs
find ~/Library/Logs -name "*.log" -mtime +14 -delete 2>/dev/null
echo "[$DATE] 🧹 macOS logs older than 14 days cleared" >> "$ROTATION_LOG"

# ─────────────────────────────────────────
# Step 4: Report disk space saved
# ─────────────────────────────────────────
FREE_SPACE=$(df -h ~ | tail -1 | awk '{print $4}')
echo "[$DATE] 💾 Free disk space: $FREE_SPACE" >> "$ROTATION_LOG"
echo "[$DATE] ✅ Log rotation complete!" >> "$ROTATION_LOG"
echo "─────────────────────────────" >> "$ROTATION_LOG"
