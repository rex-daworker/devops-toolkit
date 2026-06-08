#!/bin/bash

# ============================================
# Task #20: Master Toolkit Orchestrator
# Runs key checks & generates a summary report
# Golden rule: powerful but never
# destructive by accident
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

clear
echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        🏆  DEVOPS TOOLKIT — MASTER REPORT       ║${NC}"
echo -e "${CYAN}║        $TIMESTAMP             ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# ─── SYSTEM ───────────────────────────────────
echo -e "${BLUE}💻 SYSTEM HEALTH${NC}"
echo "──────────────────────────────────────────────"
CPU=$(sysctl -n vm.loadavg | awk '{print $2}')
DISK=$(df -h ~ | awk 'NR==2 {print $4}')
echo -e "   CPU Load   → ${GREEN}$CPU${NC}"
echo -e "   Disk Free  → ${GREEN}$DISK${NC}"
echo ""

# ─── AWS ──────────────────────────────────────
echo -e "${BLUE}☁️  AWS STATUS${NC}"
echo "──────────────────────────────────────────────"
EC2_STATE=$(aws ec2 describe-instances \
    --instance-ids i-04a687aefbf0747ea \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text 2>/dev/null)
echo -e "   EC2 State  → ${YELLOW}${EC2_STATE:-unknown}${NC}"
if aws s3 ls s3://rex-devops-toolkit &>/dev/null; then
    echo -e "   S3 Backups → ${GREEN}reachable ✅${NC}"
else
    echo -e "   S3 Backups → ${RED}unreachable ❌${NC}"
fi
echo ""

# ─── DOCKER ───────────────────────────────────
echo -e "${BLUE}🐳 DOCKER${NC}"
echo "──────────────────────────────────────────────"
if docker info &>/dev/null; then
    CONTAINERS=$(docker ps -q | wc -l | tr -d ' ')
    echo -e "   Running Containers → ${GREEN}$CONTAINERS${NC}"
else
    echo -e "   ${YELLOW}Docker not running${NC}"
fi
echo ""

# ─── SCRIPTS ──────────────────────────────────
echo -e "${BLUE}📦 TOOLKIT INVENTORY${NC}"
echo "──────────────────────────────────────────────"
SCRIPT_COUNT=$(ls ~/devops-toolkit/scripts/*.sh 2>/dev/null | wc -l | tr -d ' ')
echo -e "   Total Scripts → ${GREEN}$SCRIPT_COUNT${NC}"
echo ""

# ─── CRON ─────────────────────────────────────
echo -e "${BLUE}⏰ SCHEDULED JOBS${NC}"
echo "──────────────────────────────────────────────"
CRON_COUNT=$(crontab -l 2>/dev/null | grep -c "devops-toolkit")
echo -e "   Active Cron Jobs → ${GREEN}$CRON_COUNT${NC}"
echo ""

echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🌐 Live Site: rex-devops-toolkit-site         ║${NC}"
echo -e "${CYAN}║   📂 GitHub: github.com/rex-daworker            ║${NC}"
echo -e "${CYAN}║          ✅  Report Complete                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
