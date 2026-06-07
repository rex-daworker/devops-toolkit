#!/bin/bash

# ============================================
# Task #12: AWS Cost Report
# Pulls monthly cost data from Cost Explorer
# ============================================

LOGFILE=~/devops-toolkit/logs/cost_report.log
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
START_DATE=$(date -v-1m '+%Y-%m-01')
END_DATE=$(date '+%Y-%m-01')

echo "[$TIMESTAMP] === AWS Cost Report ===" >> "$LOGFILE"
echo "[$TIMESTAMP] Period: $START_DATE to $END_DATE" >> "$LOGFILE"

COST=$(aws ce get-cost-and-usage \
    --time-period Start=$START_DATE,End=$END_DATE \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --query 'ResultsByTime[0].Total.UnblendedCost.Amount' \
    --output text 2>/dev/null)

if [ -n "$COST" ]; then
    echo "[$TIMESTAMP] Total Cost: \$$COST" >> "$LOGFILE"
    echo "[$TIMESTAMP] ✅ Cost report complete" >> "$LOGFILE"
else
    echo "[$TIMESTAMP] ❌ Failed to retrieve cost data" >> "$LOGFILE"
fi

echo "" >> "$LOGFILE"
