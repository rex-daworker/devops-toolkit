#!/bin/bash

# ─────────────────────────────────────────
# Task #2: Daily Directory Backup
# Author: Rex | DevOps Toolkit
# Runs: Every night at midnight via cron
# Backs up: Documents, Downloads, Desktop
# ─────────────────────────────────────────

# Fix PATH for cron
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Settings
BACKUP_DEST=~/devops-toolkit/backups
LOG_FILE=~/devops-toolkit/logs/backup.log
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

# ─────────────────────────────────────────
# ADD OR REMOVE FOLDERS HERE ANYTIME
FOLDERS=(
    ~/Documents
    ~/Downloads
    ~/Desktop
)
# ─────────────────────────────────────────

echo "─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] Starting backup of all folders..." >> "$LOG_FILE"

# Loop through each folder and back it up
for FOLDER in "${FOLDERS[@]}"; do
    FOLDER_NAME=$(basename "$FOLDER")
    BACKUP_NAME="${FOLDER_NAME}_backup_${DATE}.tar.gz"

    echo "[$DATE] Backing up $FOLDER_NAME..." >> "$LOG_FILE"
    tar -czf "$BACKUP_DEST/$BACKUP_NAME" "$FOLDER" 2>> "$LOG_FILE"

    if [ $? -eq 0 ]; then
        SIZE=$(du -sh "$BACKUP_DEST/$BACKUP_NAME" | cut -f1)
        echo "[$DATE] ✅ $FOLDER_NAME done! Size: $SIZE" >> "$LOG_FILE"
    else
        echo "[$DATE] ❌ $FOLDER_NAME FAILED!" >> "$LOG_FILE"
    fi
done

# Keep only last 7 backups per folder
echo "[$DATE] 🧹 Cleaning up old backups..." >> "$LOG_FILE"
for FOLDER in "${FOLDERS[@]}"; do
    FOLDER_NAME=$(basename "$FOLDER")
    cd "$BACKUP_DEST"
    ls -t ${FOLDER_NAME}_backup_*.tar.gz 2>/dev/null | tail -n +8 | xargs rm -f
done

echo "[$DATE] 🎉 All backups complete!" >> "$LOG_FILE"
echo "─────────────────────────────" >> "$LOG_FILE"
