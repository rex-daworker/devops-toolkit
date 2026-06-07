#!/bin/bash

# ============================================
# Task #17: S3 Static Site Deploy
# Deploys website folder to S3 bucket
# ============================================

LOGFILE=~/devops-toolkit/logs/deploy_site.log
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
BUCKET="rex-devops-toolkit-site"
SITE_DIR=~/devops-toolkit/website
URL="http://rex-devops-toolkit-site.s3-website.eu-north-1.amazonaws.com"

echo "[$TIMESTAMP] === Site Deploy Started ===" >> "$LOGFILE"

aws s3 sync "$SITE_DIR" "s3://$BUCKET" \
    --exclude "*" --include "*.html" --include "*.css" --include "*.js" >> "$LOGFILE" 2>&1

if [ $? -eq 0 ]; then
    echo "[$TIMESTAMP] ✅ Site deployed successfully" >> "$LOGFILE"
    echo "[$TIMESTAMP] Live at: $URL" >> "$LOGFILE"
else
    echo "[$TIMESTAMP] ❌ Deploy failed" >> "$LOGFILE"
fi

echo "" >> "$LOGFILE"
