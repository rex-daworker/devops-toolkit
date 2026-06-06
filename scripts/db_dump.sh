#!/bin/bash

# ─────────────────────────────────────────
# Task #8: Database Dump & Compress
# Author: Rex | DevOps Toolkit
# Runs: Every day at 12:15pm via cron
# Covers: PostgreSQL, MySQL, MongoDB
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/opt/homebrew/opt/postgresql@16/bin:/usr/local/bin:$PATH"

BACKUP_DIR=~/devops-toolkit/backups/databases
LOG_FILE=~/devops-toolkit/logs/db_dump.log
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
KEEP_DAYS=7

echo "─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] 🗄️  Starting database dumps..." >> "$LOG_FILE"

# ─────────────────────────────────────────
# 1. PostgreSQL
# ─────────────────────────────────────────
echo "[$DATE] 🐘 Checking PostgreSQL..." >> "$LOG_FILE"

if brew services list | grep -q "postgresql.*started"; then
    # Get all user databases (skip system ones)
    DATABASES=$(psql -U rex postgres -t -c \
        "SELECT datname FROM pg_database
         WHERE datistemplate = false
         AND datname != 'postgres';" 2>/dev/null | tr -d ' ')

    for DB in $DATABASES; do
        DUMP_FILE="$BACKUP_DIR/postgres_${DB}_${DATE}.sql"
        COMPRESSED="$DUMP_FILE.gz"

        echo "[$DATE] Dumping PostgreSQL: $DB..." >> "$LOG_FILE"
        pg_dump -U rex "$DB" > "$DUMP_FILE" 2>/dev/null

        if [ $? -eq 0 ] && [ -s "$DUMP_FILE" ]; then
            gzip "$DUMP_FILE"
            SIZE=$(du -sh "$COMPRESSED" | cut -f1)
            echo "[$DATE] ✅ PostgreSQL $DB — Size: $SIZE" >> "$LOG_FILE"
        else
            rm -f "$DUMP_FILE"
            echo "[$DATE] ⚠️  PostgreSQL $DB — empty or failed" >> "$LOG_FILE"
        fi
    done

    # Keep only last 7 backups per database
    for DB in $DATABASES; do
        ls -t "$BACKUP_DIR"/postgres_${DB}_*.sql.gz 2>/dev/null | \
        tail -n +$((KEEP_DAYS + 1)) | xargs rm -f
    done
else
    echo "[$DATE] ⏭️  PostgreSQL not running — skipping" >> "$LOG_FILE"
fi

# ─────────────────────────────────────────
# 2. MySQL
# ─────────────────────────────────────────
echo "[$DATE] 🐬 Checking MySQL..." >> "$LOG_FILE"

if brew services list | grep -q "mysql.*started"; then
    DATABASES=$(mysql -u root -e \
        "SHOW DATABASES;" 2>/dev/null | \
        grep -Ev "^(Database|information_schema|performance_schema|mysql|sys)$")

    for DB in $DATABASES; do
        DUMP_FILE="$BACKUP_DIR/mysql_${DB}_${DATE}.sql"
        COMPRESSED="$DUMP_FILE.gz"

        echo "[$DATE] Dumping MySQL: $DB..." >> "$LOG_FILE"
        mysqldump -u root "$DB" > "$DUMP_FILE" 2>/dev/null

        if [ $? -eq 0 ] && [ -s "$DUMP_FILE" ]; then
            gzip "$DUMP_FILE"
            SIZE=$(du -sh "$COMPRESSED" | cut -f1)
            echo "[$DATE] ✅ MySQL $DB — Size: $SIZE" >> "$LOG_FILE"
        else
            rm -f "$DUMP_FILE"
            echo "[$DATE] ⚠️  MySQL $DB — empty or failed" >> "$LOG_FILE"
        fi
    done
else
    echo "[$DATE] ⏭️  MySQL not running — skipping" >> "$LOG_FILE"
fi

# ─────────────────────────────────────────
# 3. MongoDB
# ─────────────────────────────────────────
echo "[$DATE] 🍃 Checking MongoDB..." >> "$LOG_FILE"

if brew services list | grep -q "mongodb.*started"; then
    DUMP_FILE="$BACKUP_DIR/mongodb_all_${DATE}.gz"

    echo "[$DATE] Dumping MongoDB..." >> "$LOG_FILE"
    mongodump --archive="$DUMP_FILE" --gzip 2>/dev/null

    if [ $? -eq 0 ]; then
        SIZE=$(du -sh "$DUMP_FILE" | cut -f1)
        echo "[$DATE] ✅ MongoDB — Size: $SIZE" >> "$LOG_FILE"
    else
        echo "[$DATE] ⚠️  MongoDB dump failed" >> "$LOG_FILE"
    fi

    # Keep only last 7 backups
    ls -t "$BACKUP_DIR"/mongodb_all_*.gz 2>/dev/null | \
    tail -n +$((KEEP_DAYS + 1)) | xargs rm -f
else
    echo "[$DATE] ⏭️  MongoDB not running — skipping" >> "$LOG_FILE"
fi

# ─────────────────────────────────────────
# Summary
# ─────────────────────────────────────────
TOTAL=$(ls "$BACKUP_DIR"/*.gz 2>/dev/null | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)

echo "[$DATE] ─────────────────────────────" >> "$LOG_FILE"
echo "[$DATE] 📊 Total backups stored: $TOTAL" >> "$LOG_FILE"
echo "[$DATE] 💾 Total backup size: $TOTAL_SIZE" >> "$LOG_FILE"
echo "[$DATE] 🎉 Database dump complete!" >> "$LOG_FILE"
echo "─────────────────────────────" >> "$LOG_FILE"
