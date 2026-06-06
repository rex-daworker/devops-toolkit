#!/bin/bash

# ─────────────────────────────────────────
# Task #4: Docker Resource Pruning
# Author: Rex | DevOps Toolkit
# Runs: Every Sunday at 4am via cron
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

LOG_FILE=~/devops-toolkit/logs/docker_prune.log
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] Starting Docker cleanup..." >> "$LOG_FILE"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "[$DATE] ⚠️  Docker is not running — skipping" >> "$LOG_FILE"
    echo "─────────────────────────────" >> "$LOG_FILE"
    exit 1
fi

# Step 1: Remove stopped containers
echo "[$DATE] Removing stopped containers..." >> "$LOG_FILE"
CONTAINERS=$(docker container prune -f 2>&1)
echo "[$DATE] $CONTAINERS" >> "$LOG_FILE"

# Step 2: Remove unused images
echo "[$DATE] Removing unused images..." >> "$LOG_FILE"
IMAGES=$(docker image prune -af 2>&1)
echo "[$DATE] $IMAGES" >> "$LOG_FILE"

# Step 3: Remove unused volumes
echo "[$DATE] Removing unused volumes..." >> "$LOG_FILE"
VOLUMES=$(docker volume prune -f 2>&1)
echo "[$DATE] $VOLUMES" >> "$LOG_FILE"

# Step 4: Remove unused networks
echo "[$DATE] Removing unused networks..." >> "$LOG_FILE"
NETWORKS=$(docker network prune -f 2>&1)
echo "[$DATE] $NETWORKS" >> "$LOG_FILE"

# Step 5: Show disk space usage
echo "[$DATE] 📊 Docker disk usage after cleanup:" >> "$LOG_FILE"
docker system df >> "$LOG_FILE" 2>&1

echo "[$DATE] ✅ Docker cleanup complete!" >> "$LOG_FILE"
echo "─────────────────────────────" >> "$LOG_FILE"
