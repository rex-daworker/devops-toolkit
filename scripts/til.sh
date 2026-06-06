#!/bin/bash

# ─────────────────────────────────────────
# Task #9: TIL Knowledge Log
# Author: Rex | DevOps Toolkit
# Usage: til <your note here>
#        til-search <keyword>
#        til-stats
#        til-open
# ─────────────────────────────────────────

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

JOURNAL_DIR=~/Documents/til-journal
JOURNAL_FILE=$JOURNAL_DIR/journal.md
ENTRIES_DIR=$JOURNAL_DIR/entries
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
DAY=$(date '+%A')

# Create journal file if it doesn't exist
if [ ! -f "$JOURNAL_FILE" ]; then
cat > "$JOURNAL_FILE" << 'HEADER'
# Rex's TIL Journal 📖
> A daily log of everything I learn as a DevOps engineer

---

HEADER
fi

# ─────────────────────────────────────────
# COMMANDS
# ─────────────────────────────────────────

case "$1" in

    # ─── Search entries ───
    search)
        KEYWORD="$2"
        if [ -z "$KEYWORD" ]; then
            echo "Usage: til search <keyword>"
            exit 1
        fi
        echo ""
        echo "🔍 Searching for: '$KEYWORD'"
        echo "─────────────────────────────"
        grep -n -i "$KEYWORD" "$JOURNAL_FILE" | \
        grep -v "^.*:#" | \
        sed 's/^/  /'
        echo ""
        ;;

    # ─── Show stats ───
    stats)
        echo ""
        echo "📖 TIL Journal Statistics"
        echo "─────────────────────────"
        TOTAL=$(grep -c "^- " "$JOURNAL_FILE" 2>/dev/null || echo 0)
        DAYS=$(grep -c "^## " "$JOURNAL_FILE" 2>/dev/null || echo 0)
        FIRST=$(grep "^## " "$JOURNAL_FILE" 2>/dev/null | head -1 | awk '{print $2}')
        LATEST=$(grep "^## " "$JOURNAL_FILE" 2>/dev/null | tail -1 | awk '{print $2}')
        echo "  Total entries  : $TOTAL"
        echo "  Days logged    : $DAYS"
        echo "  First entry    : $FIRST"
        echo "  Latest entry   : $LATEST"
        echo ""
        ;;

    # ─── Open journal ───
    open)
        echo "📖 Opening TIL Journal..."
        cat "$JOURNAL_FILE"
        ;;

    # ─── Add new entry (default) ───
    *)
        NOTE="$*"
        if [ -z "$NOTE" ]; then
            echo ""
            echo "📖 TIL — Today I Learned"
            echo "─────────────────────────"
            echo "Usage:"
            echo "  til <your note>           → add entry"
            echo "  til search <keyword>      → search entries"
            echo "  til stats                 → show statistics"
            echo "  til open                  → view full journal"
            echo ""
            exit 0
        fi

        # Check if today's header already exists
        if ! grep -q "^## $DATE" "$JOURNAL_FILE"; then
            echo "" >> "$JOURNAL_FILE"
            echo "## $DATE — $DAY" >> "$JOURNAL_FILE"
        fi


	# Check for --code flag
        if echo "$*" | grep -q "\-\-code"; then
            NOTE=$(echo "$*" | sed 's/--code.*//' | xargs)
            CODE=$(echo "$*" | sed 's/.*--code //')

            # Add entry with code block
            echo "- [$TIME] $NOTE" >> "$JOURNAL_FILE"
            echo '  ```bash' >> "$JOURNAL_FILE"
            echo "  $CODE" >> "$JOURNAL_FILE"
            echo '  ```' >> "$JOURNAL_FILE"

            echo "- [$TIME] $NOTE" >> "$ENTRIES_DIR/$DATE.md"
            echo '  ```bash' >> "$ENTRIES_DIR/$DATE.md"
            echo "  $CODE" >> "$ENTRIES_DIR/$DATE.md"
            echo '  ```' >> "$ENTRIES_DIR/$DATE.md"
        else
            # Regular entry
            echo "- [$TIME] $NOTE" >> "$JOURNAL_FILE"
            echo "- [$TIME] $NOTE" >> "$ENTRIES_DIR/$DATE.md"
        fi
        echo ""
        echo "✅ TIL saved!"
        echo "   📅 $DATE $TIME"
        echo "   📝 $NOTE"
        echo ""
        ;;
esac
