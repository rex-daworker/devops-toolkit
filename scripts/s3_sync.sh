#!/bin/bash

# ─────────────────────────────────────────
# Task #10: Sync Backups to AWS S3
# Author: Rex | DevOps Toolkit
# Runs: Every day at 12:20pm via cron
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

LOG_FILE=~/devops-toolkit/logs/s3_sync.log
DATE=$(date '+%Y-%m-%d %H:%M:%S')
BACKUP_DIR=~/devops-toolkit/backups
BUCKET="s3://rex-devops-toolkit"

echo "─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] ☁️  Starting S3 sync..." >> "$LOG_FILE"

# Check internet connection
if ! ping -c 1 aws.amazon.com &> /dev/null; then
    echo "[$DATE] ⚠️  No internet — skipping sync" >> "$LOG_FILE"
    echo "─────────────────────────────" >> "$LOG_FILE"
    exit 1
fi

# Sync backups to S3
echo "[$DATE] Syncing backups to $BUCKET..." >> "$LOG_FILE"
RESULT=$(aws s3 sync "$BACKUP_DIR" "$BUCKET/backups/" \
    --region eu-north-1 \
    --exclude "*.DS_Store" \
    2>&1)

if [ $? -eq 0 ]; then
    # Count files in S3
    FILE_COUNT=$(aws s3 ls "$BUCKET/backups/" \
        --recursive --region eu-north-1 2>/dev/null | wc -l | tr -d ' ')
    
    # Get total size in S3
    TOTAL_SIZE=$(aws s3 ls "$BUCKET/backups/" \
        --recursive --human-readable --region eu-north-1 2>/dev/null | \
        tail -1 | awk '{print $3,$4}')

    echo "[$DATE] ✅ Sync complete!" >> "$LOG_FILE"
    echo "[$DATE] 📊 Files in S3: $FILE_COUNT" >> "$LOG_FILE"
    echo "[$DATE] 💾 Total size: $TOTAL_SIZE" >> "$LOG_FILE"
else
    echo "[$DATE] ❌ Sync failed!" >> "$LOG_FILE"
    echo "$RESULT" >> "$LOG_FILE"
fi

# Also sync TIL journal
echo "[$DATE] Syncing TIL journal..." >> "$LOG_FILE"
aws s3 sync ~/Documents/til-journal "$BUCKET/til-journal/" \
    --region eu-north-1 2>/dev/null

echo "[$DATE] 🎉 All done!" >> "$LOG_FILE"
echo "─────────────────────────────" >> "$LOG_FILE"
