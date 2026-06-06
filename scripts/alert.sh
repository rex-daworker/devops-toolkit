#!/bin/bash

# ============================================
# Task #16: Alert System (Slack + Email)
# Usage: source alert.sh then call send_alert
# ============================================

LOGFILE=~/devops-toolkit/logs/alerts.log
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

send_alert() {
    local SCRIPT_NAME="$1"
    local MESSAGE="$2"

    echo "[$TIMESTAMP] ALERT from $SCRIPT_NAME: $MESSAGE" >> "$LOGFILE"

    # ── Slack Alert ──────────────────────────
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -s -X POST "$SLACK_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"text\": \"🚨 *DEVOPS ALERT*\n─────────────────\n*Script:* $SCRIPT_NAME\n*Status:* $MESSAGE\n*Time:* $TIMESTAMP\n*Machine:* $(hostname)\"
            }" > /dev/null
        echo "[$TIMESTAMP] Slack alert sent ✅" >> "$LOGFILE"
    else
        echo "[$TIMESTAMP] Slack webhook not set ⚠️" >> "$LOGFILE"
    fi

    # ── Email Alert ──────────────────────────
    if [ -n "$OUTLOOK_EMAIL" ] && [ -n "$OUTLOOK_PASSWORD" ]; then
        curl -s \
            --url "smtps://smtp-mail.outlook.com:587" \
            --ssl-reqd \
            --mail-from "$OUTLOOK_EMAIL" \
            --mail-rcpt "$OUTLOOK_EMAIL" \
            --user "$OUTLOOK_EMAIL:$OUTLOOK_PASSWORD" \
            -T <(echo -e "From: $OUTLOOK_EMAIL\nTo: $OUTLOOK_EMAIL\nSubject: 🚨 DevOps Alert: $SCRIPT_NAME\n\nScript: $SCRIPT_NAME\nStatus: $MESSAGE\nTime: $TIMESTAMP\nMachine: $(hostname)") > /dev/null
        echo "[$TIMESTAMP] Email alert sent ✅" >> "$LOGFILE"
    else
        echo "[$TIMESTAMP] Email credentials not set ⚠️" >> "$LOGFILE"
    fi
}
