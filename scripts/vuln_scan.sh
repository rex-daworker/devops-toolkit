#!/bin/bash

# ─────────────────────────────────────────
# Task #7: Multi-Language Vulnerability Scan
# Author: Rex | DevOps Toolkit
# Runs: Every Monday at 6am via cron
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/usr/local/bin:/Users/rex/Library/Python/3.9/bin:$PATH"

LOG_FILE=~/devops-toolkit/logs/vuln_scan.log
DATE=$(date '+%Y-%m-%d %H:%M:%S')
REPOS_DIR=~/Projects/repos

# Counters
PYTHON_VULN=0
JS_VULN=0
GO_VULN=0
SHELL_ISSUES=0
TOTAL_CLEAN=0

> "$LOG_FILE"  # Clear log each run for clean report

cat >> "$LOG_FILE" << 'HEADER'
╔══════════════════════════════════════════════════════╗
║         DEVOPS TOOLKIT — VULNERABILITY REPORT        ║
╚══════════════════════════════════════════════════════╝
HEADER

echo "  Generated: $DATE" >> "$LOG_FILE"
echo "  Scanning:  ~/Projects/repos" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# ─────────────────────────────────────────
# 1. PYTHON — pip-audit
# ─────────────────────────────────────────
cat >> "$LOG_FILE" << 'SECTION'
┌──────────────────────────────────────────────────────┐
│  🐍  PYTHON PROJECTS (pip-audit)                     │
└──────────────────────────────────────────────────────┘
SECTION

for REPO in "$REPOS_DIR"/*/; do
    REPO_NAME=$(basename "$REPO")
    if [ -f "$REPO/requirements.txt" ]; then
        RESULT=$(pip-audit -r "$REPO/requirements.txt" 2>&1)
        if echo "$RESULT" | grep -q "No known vulnerabilities"; then
            echo "  ✅  $REPO_NAME — clean" >> "$LOG_FILE"
            TOTAL_CLEAN=$((TOTAL_CLEAN + 1))
        else
            echo "" >> "$LOG_FILE"
            echo "  🚨  $REPO_NAME — VULNERABILITIES FOUND:" >> "$LOG_FILE"
            echo "$RESULT" | grep -E "^(Name|---|pillow|requests|django|flask|numpy)" | \
            while IFS= read -r line; do
                echo "      $line" >> "$LOG_FILE"
            done
            echo "  💡  Fix: pip install --upgrade <package>" >> "$LOG_FILE"
            echo "" >> "$LOG_FILE"
            PYTHON_VULN=$((PYTHON_VULN + 1))
        fi
    fi
done
echo "" >> "$LOG_FILE"

# ─────────────────────────────────────────
# 2. JAVASCRIPT & TYPESCRIPT — npm audit
# ─────────────────────────────────────────
cat >> "$LOG_FILE" << 'SECTION'
┌──────────────────────────────────────────────────────┐
│  📦  JAVASCRIPT / TYPESCRIPT PROJECTS (npm audit)    │
└──────────────────────────────────────────────────────┘
SECTION

for REPO in "$REPOS_DIR"/*/; do
    REPO_NAME=$(basename "$REPO")
    if [ -f "$REPO/package.json" ]; then
        cd "$REPO" || continue
        if [ ! -d "node_modules" ]; then
            npm install --silent 2>/dev/null
        fi
        RESULT=$(npm audit 2>&1)
        SUMMARY=$(echo "$RESULT" | grep -E "found [0-9]+ vulnerabilit")
        if echo "$RESULT" | grep -q "found 0 vulnerabilities"; then
            echo "  ✅  $REPO_NAME — clean" >> "$LOG_FILE"
            TOTAL_CLEAN=$((TOTAL_CLEAN + 1))
        else
            echo "" >> "$LOG_FILE"
            echo "  🚨  $REPO_NAME — $SUMMARY" >> "$LOG_FILE"
            # Show only severity summary
            echo "$RESULT" | grep -E "^(critical|high|moderate|low)" | sort -u | \
            while IFS= read -r line; do
                echo "      ⚠️   $line" >> "$LOG_FILE"
            done
            echo "  💡  Fix: cd ~/Projects/repos/$REPO_NAME && npm audit fix" >> "$LOG_FILE"
            echo "" >> "$LOG_FILE"
            JS_VULN=$((JS_VULN + 1))
        fi
    fi
done
echo "" >> "$LOG_FILE"

# ─────────────────────────────────────────
# 3. GO — govulncheck
# ─────────────────────────────────────────
cat >> "$LOG_FILE" << 'SECTION'
┌──────────────────────────────────────────────────────┐
│  🐹  GO PROJECTS (govulncheck)                       │
└──────────────────────────────────────────────────────┘
SECTION

for REPO in "$REPOS_DIR"/*/; do
    REPO_NAME=$(basename "$REPO")
    if [ -f "$REPO/go.mod" ]; then
        cd "$REPO" || continue
        RESULT=$(govulncheck ./... 2>&1)
        if echo "$RESULT" | grep -q "No vulnerabilities found"; then
            echo "  ✅  $REPO_NAME — clean" >> "$LOG_FILE"
            TOTAL_CLEAN=$((TOTAL_CLEAN + 1))
        else
            echo "  🚨  $REPO_NAME — vulnerabilities found" >> "$LOG_FILE"
            echo "  💡  Fix: go get -u && go mod tidy" >> "$LOG_FILE"
            GO_VULN=$((GO_VULN + 1))
        fi
    fi
done
echo "" >> "$LOG_FILE"

# ─────────────────────────────────────────
# 4. BASH — shellcheck
# ─────────────────────────────────────────
cat >> "$LOG_FILE" << 'SECTION'
┌──────────────────────────────────────────────────────┐
│  🐚  BASH/SHELL SCRIPTS (shellcheck)                 │
└──────────────────────────────────────────────────────┘
SECTION

for SCRIPT in ~/devops-toolkit/scripts/*.sh; do
    SCRIPT_NAME=$(basename "$SCRIPT")
    RESULT=$(shellcheck "$SCRIPT" 2>&1)
    if [ -z "$RESULT" ]; then
        echo "  ✅  $SCRIPT_NAME — clean" >> "$LOG_FILE"
        TOTAL_CLEAN=$((TOTAL_CLEAN + 1))
    else
        ISSUE_COUNT=$(echo "$RESULT" | grep -c "^In")
        echo "  ⚠️   $SCRIPT_NAME — $ISSUE_COUNT style suggestion(s) (not critical)" >> "$LOG_FILE"
        SHELL_ISSUES=$((SHELL_ISSUES + 1))
    fi
done
echo "" >> "$LOG_FILE"

# ─────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────
cat >> "$LOG_FILE" << 'SECTION'
╔══════════════════════════════════════════════════════╗
║                    SCAN SUMMARY                      ║
╚══════════════════════════════════════════════════════╝
SECTION

TOTAL_VULN=$((PYTHON_VULN + JS_VULN + GO_VULN))
echo "  🐍  Python vulnerable projects : $PYTHON_VULN" >> "$LOG_FILE"
echo "  📦  JS/TS vulnerable projects  : $JS_VULN" >> "$LOG_FILE"
echo "  🐹  Go vulnerable projects     : $GO_VULN" >> "$LOG_FILE"
echo "  🐚  Shell scripts with hints   : $SHELL_ISSUES (style only)" >> "$LOG_FILE"
echo "  ✅  Clean projects             : $TOTAL_CLEAN" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

if [ $TOTAL_VULN -eq 0 ]; then
    echo "  🎉  ALL CLEAR — No critical vulnerabilities found!" >> "$LOG_FILE"
else
    echo "  🚨  ACTION REQUIRED — $TOTAL_VULN project(s) need attention!" >> "$LOG_FILE"
    echo "  📋  Check sections above for fix commands." >> "$LOG_FILE"
fi
echo "" >> "$LOG_FILE"
echo "  Scan completed: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
