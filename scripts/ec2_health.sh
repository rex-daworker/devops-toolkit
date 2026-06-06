#!/bin/bash

# ─────────────────────────────────────────
# Task #11: EC2 Health Checks
# Author: Rex | DevOps Toolkit
# Runs: Every day at 12:25pm via cron
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

LOG_FILE=~/devops-toolkit/logs/ec2_health.log
DATE=$(date '+%Y-%m-%d %H:%M:%S')
REGION="eu-north-1"
UNHEALTHY=0
TOTAL=0

echo "─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] 🖥️  Starting EC2 health checks..." >> "$LOG_FILE"

# Check internet connection
if ! ping -c 1 aws.amazon.com &> /dev/null; then
    echo "[$DATE] ⚠️  No internet — skipping" >> "$LOG_FILE"
    echo "─────────────────────────────" >> "$LOG_FILE"
    exit 1
fi

# ─────────────────────────────────────────
# Get all EC2 instances
# ─────────────────────────────────────────
INSTANCES=$(aws ec2 describe-instances \
    --region "$REGION" \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
    --output text 2>/dev/null)

# Check if any instances exist
if [ -z "$INSTANCES" ]; then
    echo "[$DATE] ℹ️  No EC2 instances found in $REGION" >> "$LOG_FILE"
    echo "[$DATE] 💡 Launch an EC2 instance to start monitoring" >> "$LOG_FILE"
    echo "[$DATE] ✅ Health check complete — nothing to monitor yet" >> "$LOG_FILE"
    echo "─────────────────────────────" >> "$LOG_FILE"
    exit 0
fi

# ─────────────────────────────────────────
# Check each instance
# ─────────────────────────────────────────
while IFS=$'\t' read -r INSTANCE_ID STATE NAME PUBLIC_IP; do
    TOTAL=$((TOTAL + 1))
    NAME=${NAME:-"unnamed"}
    PUBLIC_IP=${PUBLIC_IP:-"no-public-ip"}

    echo "[$DATE] Checking $NAME ($INSTANCE_ID)..." >> "$LOG_FILE"

    # Check instance state
    case "$STATE" in
        running)
            # Get status checks
            STATUS=$(aws ec2 describe-instance-status \
                --region "$REGION" \
                --instance-ids "$INSTANCE_ID" \
                --query 'InstanceStatuses[0].[SystemStatus.Status,InstanceStatus.Status]' \
                --output text 2>/dev/null)

            SYS_STATUS=$(echo "$STATUS" | awk '{print $1}')
            INST_STATUS=$(echo "$STATUS" | awk '{print $2}')

            if [ "$SYS_STATUS" = "ok" ] && [ "$INST_STATUS" = "ok" ]; then
                echo "[$DATE] ✅ $NAME — running | System: ok | Instance: ok | IP: $PUBLIC_IP" >> "$LOG_FILE"
            else
                echo "[$DATE] ❌ $NAME — STATUS FAILED! System: $SYS_STATUS | Instance: $INST_STATUS" >> "$LOG_FILE"
                UNHEALTHY=$((UNHEALTHY + 1))
            fi
            ;;
        stopped)
            echo "[$DATE] ⚠️  $NAME — STOPPED | IP: $PUBLIC_IP" >> "$LOG_FILE"
            UNHEALTHY=$((UNHEALTHY + 1))
            ;;
        terminated)
            echo "[$DATE] 💀 $NAME — TERMINATED" >> "$LOG_FILE"
            ;;
        pending)
            echo "[$DATE] 🔄 $NAME — Starting up..." >> "$LOG_FILE"
            ;;
        *)
            echo "[$DATE] ❓ $NAME — Unknown state: $STATE" >> "$LOG_FILE"
            UNHEALTHY=$((UNHEALTHY + 1))
            ;;
    esac
done <<< "$INSTANCES"

# ─────────────────────────────────────────
# Summary
# ─────────────────────────────────────────
echo "[$DATE] ─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] 📊 Total instances checked: $TOTAL" >> "$LOG_FILE"

if [ $UNHEALTHY -eq 0 ]; then
    echo "[$DATE] 🎉 All instances healthy!" >> "$LOG_FILE"
else
    echo "[$DATE] 🚨 $UNHEALTHY instance(s) need attention!" >> "$LOG_FILE"
fi
echo "─────────────────────────────" >> "$LOG_FILE"
