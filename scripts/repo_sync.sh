#!/bin/bash

# ─────────────────────────────────────────
# Task #5: Morning Repo Sync
# Author: Rex | DevOps Toolkit
# Runs: Every day at 7am via cron
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

LOG_FILE=~/devops-toolkit/logs/repo_sync.log
DATE=$(date '+%Y-%m-%d %H:%M:%S')
REPOS_DIR=~/Projects/repos

echo "─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] Starting morning repo sync..." >> "$LOG_FILE"

# Check internet connection first
if ! ping -c 1 github.com &> /dev/null; then
    echo "[$DATE] ⚠️  No internet connection — skipping sync" >> "$LOG_FILE"
    echo "─────────────────────────────" >> "$LOG_FILE"
    exit 1
fi

# Loop through every repo folder
for REPO in "$REPOS_DIR"/*/; do
    REPO_NAME=$(basename "$REPO")

    # Check if it's actually a git repo
    if [ ! -d "$REPO/.git" ]; then
        echo "[$DATE] ⏭️  Skipping $REPO_NAME — not a git repo" >> "$LOG_FILE"
        continue
    fi

    echo "[$DATE] Syncing $REPO_NAME..." >> "$LOG_FILE"
    cd "$REPO"

    # Get current branch name
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Pull latest changes
    RESULT=$(git pull origin "$BRANCH" 2>&1)

    if echo "$RESULT" | grep -q "Already up to date"; then
        echo "[$DATE] ✅ $REPO_NAME — already up to date" >> "$LOG_FILE"
    elif echo "$RESULT" | grep -q "error\|fatal"; then
        echo "[$DATE] ❌ $REPO_NAME — error: $RESULT" >> "$LOG_FILE"
    else
        echo "[$DATE] 🔄 $REPO_NAME — updated successfully!" >> "$LOG_FILE"
    fi
done

echo "[$DATE] 🎉 All repos synced!" >> "$LOG_FILE"
echo "─────────────────────────────" >> "$LOG_FILE"
