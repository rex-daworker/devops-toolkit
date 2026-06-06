#!/bin/bash
source ~/.devops_secrets
source ~/devops-toolkit/scripts/alert.sh
# ============================================
# Task #13: Terraform Drift Detection
# Checks EC2 state vs expected baseline
# ============================================

LOGFILE=~/devops-toolkit/logs/drift_detect.log
TERRAFORM_DIR=~/devops-toolkit/terraform
EXPECTED_TYPE="t3.micro"
EXPECTED_STATE="stopped"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] === Drift Detection Started ===" >> "$LOGFILE"
send_alert "drift_detect.sh" "⚠️ DRIFT DETECTED: instance_type changed to $CURRENT_TYPE"
# Move into terraform directory
cd "$TERRAFORM_DIR" || exit 1

# Run terraform refresh to get latest state
terraform apply -refresh-only -auto-approve > /tmp/tf_refresh.log 2>&1

# Get current values
CURRENT_TYPE=$(terraform output -raw instance_type 2>/dev/null)
CURRENT_STATE=$(terraform output -raw instance_state 2>/dev/null)

echo "[$TIMESTAMP] Expected → type: $EXPECTED_TYPE | state: $EXPECTED_STATE" >> "$LOGFILE"
echo "[$TIMESTAMP] Actual   → type: $CURRENT_TYPE | state: $CURRENT_STATE" >> "$LOGFILE"

DRIFT=false

# Check instance type
if [ "$CURRENT_TYPE" != "$EXPECTED_TYPE" ]; then
    "echo "[$TIMESTAMP] ⚠️  DRIFT DETECTED: instance_type changed → $CURRENT_TYPE" >> "$LOGFILE"
    send_alert "drift_detect.sh" "⚠️ DRIFT DETECTED: instance_type changed to $CURRENT_TYPE"
	DRIFT=true
fi

# Check instance state
if [ "$CURRENT_STATE" != "$EXPECTED_STATE" ]; then
    echo "[$TIMESTAMP] ⚠️  DRIFT DETECTED: instance_state is → $CURRENT_STATE (expected: $EXPECTED_STATE)" >> "$LOGFILE"
    send_alert "drift_detect.sh" "⚠️ DRIFT DETECTED: instance_type changed to $CURRENT_TYPE"
	 DRIFT=true
fi

if [ "$DRIFT" = false ]; then
    echo "[$TIMESTAMP] ✅ No drift detected. Infrastructure matches baseline." >> "$LOGFILE"
fi

echo "[$TIMESTAMP] === Drift Detection Complete ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"
