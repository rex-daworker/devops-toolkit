#!/bin/bash

# ============================================
# Task #19: Git Branch Cleanup
# Safely deletes merged branches
# Golden rule: powerful but never
# destructive by accident
# ============================================

LOGFILE=~/devops-toolkit/logs/branch_cleanup.log
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Protected branches that must NEVER be deleted
PROTECTED="main master develop"

echo "[$TIMESTAMP] === Branch Cleanup Started ===" >> "$LOGFILE"

# Make sure we're on main first
git checkout main &>/dev/null

# Find branches already merged into main
MERGED=$(git branch --merged main | grep -v '\*' | tr -d ' ')

if [ -z "$MERGED" ]; then
    echo "[$TIMESTAMP] No merged branches to clean up" >> "$LOGFILE"
    echo "✅ No merged branches found."
    exit 0
fi

echo "The following merged branches can be safely deleted:"
echo ""

# Build a list, skipping protected branches
DELETABLE=""
for BRANCH in $MERGED; do
    SKIP=false
    for P in $PROTECTED; do
        if [ "$BRANCH" = "$P" ]; then
            SKIP=true
        fi
    done
    if [ "$SKIP" = false ]; then
        echo "  🌿 $BRANCH"
        DELETABLE="$DELETABLE $BRANCH"
    fi
done

if [ -z "$DELETABLE" ]; then
    echo "✅ Only protected branches remain. Nothing to delete."
    echo "[$TIMESTAMP] Only protected branches remain" >> "$LOGFILE"
    exit 0
fi

echo ""
read -p "Delete these branches? (y/n): " CONFIRM

if [ "$CONFIRM" = "y" ]; then
    for BRANCH in $DELETABLE; do
        git branch -d "$BRANCH" &>/dev/null
        echo "[$TIMESTAMP] Deleted branch: $BRANCH" >> "$LOGFILE"
        echo "  ✅ Deleted $BRANCH"
    done
else
    echo "  ❌ Cancelled. No branches deleted."
    echo "[$TIMESTAMP] Cleanup cancelled by user" >> "$LOGFILE"
fi

echo "[$TIMESTAMP] === Branch Cleanup Complete ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"
