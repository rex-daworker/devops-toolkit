#!/bin/bash

LOGDIR=~/devops-toolkit/logs
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🎛️  DEVOPS TOOLKIT HEALTH DASHBOARD     ║${NC}"
echo -e "${CYAN}║   Generated: $TIMESTAMP   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}💻 SYSTEM${NC}"
echo "───────────────────────────────────────────"
CPU=$(sysctl -n vm.loadavg | awk '{print $2}')
MEM_TOTAL=$(sysctl -n hw.memsize | awk '{printf "%.0fGB", $1/1024/1024/1024}')
MEM_USED=$(vm_stat | awk '/Pages active/ {print $3}' | tr -d '.' | awk '{printf "%.1fGB", $1*4096/1024/1024/1024}')
DISK=$(df -h ~ | awk 'NR==2 {print $4}')
echo -e "   CPU Load    → ${GREEN}$CPU${NC}"
echo -e "   Memory      → ${GREEN}$MEM_USED / $MEM_TOTAL${NC}"
echo -e "   Disk Free   → ${GREEN}$DISK${NC}"
echo ""
echo -e "${BLUE}🐳 DOCKER${NC}"
echo "───────────────────────────────────────────"
if command -v docker &>/dev/null; then
    CONTAINERS=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
    IMAGES=$(docker images -q 2>/dev/null | wc -l | tr -d ' ')
    echo -e "   Running Containers → ${GREEN}$CONTAINERS${NC}"
    echo -e "   Images Available   → ${GREEN}$IMAGES${NC}"
else
    echo -e "   ${YELLOW}Docker not running${NC}"
fi
echo ""
echo -e "${BLUE}☁️  AWS${NC}"
echo "───────────────────────────────────────────"
EC2_STATE=$(aws ec2 describe-instances \
    --instance-ids i-04a687aefbf0747ea \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text 2>/dev/null)
if [ "$EC2_STATE" = "running" ]; then
    echo -e "   EC2 State  → ${GREEN}$EC2_STATE✅${NC}"
elif [ "$EC2_STATE" = "stopped" ]; then
    echo -e "   EC2 State  → ${YELLOW}$EC2_STATE ⚠️${NC}"
else
    echo -e "   EC2 State  → ${RED}unknown❌${NC}"
fi
if aws s3 ls s3://rex-devops-toolkit &>/dev/null; then
    echo -e "   S3 Bucket  → ${GREEN}reachable✅${NC}"
else
    echo -e "   S3 Bucket  → ${RED}unreachable❌${NC}"
fi
echo ""
echo -e "${BLUE}📜 RECENT LOG ACTIVITY${NC}"
echo "───────────────────────────────────────────"
for LOG in backup ec2_health drift_detect s3_sync db_dump; do
    if [ -f "$LOGDIR/${LOG}.log" ]; then
	LAST=$(grep -v '^\s*$' "$LOGDIR/${LOG}.log" | tail -1 | cut -c1-19)
        echo -e "   ${LOG}.log → last: ${GREEN}$LAST${NC}"
    else
        echo -e "   ${LOG}.log → ${YELLOW}no log yet${NC}"
    fi
done
echo ""
SCRIPT_COUNT=$(ls ~/devops-toolkit/scripts/*.sh 2>/dev/null | wc -l | tr -d ' ')
echo -e "${BLUE}📦 SCRIPTS IN TOOLKIT → ${GREEN}$SCRIPT_COUNT scripts${NC}"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           ✅ Dashboard Complete           ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
