#!/bin/bash

# ============================================
# Task #18: Docker Container Monitor
# Monitors running containers + resource usage
# ============================================

source ~/.devops_secrets 2>/dev/null
source ~/devops-toolkit/scripts/alert.sh 2>/dev/null

LOGFILE=~/devops-toolkit/logs/docker_monitor.log
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] === Docker Monitor Started ===" >> "$LOGFILE"

# Check if Docker is running
if ! docker info &>/dev/null; then
    echo "[$TIMESTAMP] ❌ Docker is not running" >> "$LOGFILE"
    exit 1
fi

# Count running containers
RUNNING=$(docker ps -q | wc -l | tr -d ' ')
echo "[$TIMESTAMP] Running containers: $RUNNING" >> "$LOGFILE"

# Loop through each running container
docker ps --format '{{.Names}}' | while read -r NAME; do
    STATS=$(docker stats --no-stream --format "{{.CPUPerc}} {{.MemPerc}}" "$NAME")
    CPU=$(echo "$STATS" | awk '{print $1}')
    MEM=$(echo "$STATS" | awk '{print $2}')
    echo "[$TIMESTAMP] $NAME → CPU: $CPU | MEM: $MEM" >> "$LOGFILE"
done

# Check for any stopped/exited containers
EXITED=$(docker ps -a --filter "status=exited" --format '{{.Names}}')
if [ -n "$EXITED" ]; then
    echo "[$TIMESTAMP] ⚠️  Stopped containers detected: $EXITED" >> "$LOGFILE"
    send_alert "docker_monitor.sh" "⚠️ Stopped containers: $EXITED"
fi

echo "[$TIMESTAMP] === Docker Monitor Complete ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"
