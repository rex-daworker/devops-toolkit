#!/bin/bash

# ============================================
# Task #16: Alert System (Slack + Email)
# Usage: source alert.sh then call send_alert
# ============================================

LOGFILE=~/devops-toolkit/logs/alerts.log

send_alert() {
    local SCRIPT_NAME="$1"
    local MESSAGE="$2"
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$TIMESTAMP] ALERT from $SCRIPT_NAME: $MESSAGE" >> "$LOGFILE"

    # ── Slack Alert ──────────────────────────
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -s -X POST "$SLACK_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{\"text\": \"🚨 *DEVOPS ALERT*\n─────────────────\n*Script:* $SCRIPT_NAME\n*Status:* $MESSAGE\n*Time:* $TIMESTAMP\n*Machine:* $(hostname)\"}" > /dev/null
        echo "[$TIMESTAMP] Slack alert sent ✅" >> "$LOGFILE"
    else
        echo "[$TIMESTAMP] Slack webhook not set ⚠️" >> "$LOGFILE"
    fi

    # ── Email Alert ──────────────────────────
    if [ -n "$OUTLOOK_EMAIL" ] && [ -n "$OUTLOOK_PASSWORD" ]; then
        python3 ~/devops-toolkit/scripts/send_email.py \
            "$OUTLOOK_EMAIL" \
            "$OUTLOOK_PASSWORD" \
            "$SCRIPT_NAME" \
            "$MESSAGE" \
            "$TIMESTAMP" \
            "$(hostname)"
        echo "[$TIMESTAMP] Email alert sent ✅" >> "$LOGFILE"
    else
        echo "[$TIMESTAMP] Email credentials not set ⚠️" >> "$LOGFILE"
    fi
}
