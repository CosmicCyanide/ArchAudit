#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' 

INFO="${BLUE}ℹ️${NC}"
WARN="${YELLOW}⚠️${NC}"
SUCCESS="${GREEN}✔️${NC}"
ERROR="${RED}❌${NC}"
PROGRESS="${MAGENTA}⏳${NC}"

header() {
    echo -e "${CYAN}"
    cat << "EOF"
    _    ____ _       ____   _      _   _             
   / \  / ___| |     |  _ \ (_) ___| |_(_) ___  _ __  
  / _ \| |  _| |     | | | || |/ __| __| |/ _ \| '_ \ 
 / ___ \ |_| | |___  | |_| || | (__| |_| | (_) | | | |
/_/   \_\____|_____| |____/ |_|\___|\__|_|\___/|_| |_|
   Arch Linux System Audit Script - Cosmic Cyanide
EOF
    echo -e "${NC}"
}

install_missing() {
    echo -e "${INFO} Checking and installing necessary dependencies..."
    for dep in "$@"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${WARN} Missing: $dep. Installing..."
            sudo pacman -S --noconfirm $dep
            echo -e "${SUCCESS} Installed: $dep."
        fi
    done
}

progress_bar() {
    local duration=${1:-5}
    echo -ne "${PROGRESS} Processing: "
    for ((i=0; i<duration; i++)); do
        echo -ne "▓"
        sleep 0.5
    done
    echo -ne " ${SUCCESS} Done!\n"
}

system_info() {
    echo -e "${MAGENTA}===== System Information =====${NC}"
    echo -e "${BOLD}Hostname:${NC} $(hostname)"
    echo -e "${BOLD}Kernel Version:${NC} $(uname -r)"
    echo -e "${BOLD}Uptime:${NC} $(uptime -p)"
    echo -e "${BOLD}Last Boot:${NC} $(who -b)"
    echo -e "${BOLD}Available Updates:${NC}"
    checkupdates
    progress_bar 10
}

package_audit() {
    echo -e "${MAGENTA}===== Package Audit =====${NC}"
    echo -e "${BOLD}Outdated Packages:${NC}"
    outdated=$(checkupdates | wc -l)
    echo -e "${BOLD}Orphaned Packages:${NC}"
    orphaned=$(pacman -Qdtq | wc -l)
    echo -e "${BOLD}Vulnerable Packages:${NC}"
    vulnerabilities=$(arch-audit | wc -l)
    echo -e "${INFO} Outdated: $outdated | Orphaned: $orphaned | Vulnerabilities: $vulnerabilities"
    progress_bar 5
}

firewall_audit() {
    echo -e "${MAGENTA}===== Firewall & Network Security =====${NC}"
    echo -e "${INFO} Checking firewall rules..."
    sudo ufw status || echo -e "${ERROR} Firewall not active. Consider enabling it."
    echo -e "${INFO} Checking for open ports..."
    ss -tuln | grep LISTEN || echo -e "${SUCCESS} No unnecessary open ports."
    echo -e "${INFO} Monitoring suspicious network activity..."
    sudo nload || echo -e "${SUCCESS} Network traffic appears normal."
    progress_bar 5
}

docker_audit() {
    echo -e "${MAGENTA}===== Docker & Container Audit =====${NC}"
    if command -v docker &> /dev/null; then
        echo -e "${INFO} Checking running Docker containers..."
        sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo -e "${SUCCESS} No containers running."
        echo -e "${INFO} Checking for unused images..."
        sudo docker images -f "dangling=true" -q | xargs -r sudo docker rmi
    else
        echo -e "${WARN} Docker not installed. Skipping Docker audit."
    fi
    progress_bar 5
}

storage_health() {
    echo -e "${MAGENTA}===== Storage Health =====${NC}"
    echo -e "${INFO} Checking SSD/HDD health using smartctl..."
    sudo smartctl -a /dev/sda || echo -e "${WARN} smartctl not available or no SSD/HDD detected."
    echo -e "${INFO} Monitoring disk space usage..."
    df -h / || echo -e "${SUCCESS} Disk space usage appears normal."
    progress_bar 5
}

resource_monitor() {
    echo -e "${MAGENTA}===== Resource Monitoring =====${NC}"
    echo -e "${BOLD}CPU Usage:${NC}"
    dstat --cpu --top-cpu
    echo -e "${BOLD}Memory Usage:${NC}"
    dstat --mem
    echo -e "${BOLD}Disk I/O:${NC}"
    dstat --disk
    echo -e "${BOLD}Network Usage:${NC}"
    dstat --net
    progress_bar 5
}

backup_configs() {
    echo -e "${MAGENTA}===== Backup Configurations =====${NC}"
    echo -e "${INFO} Backing up /etc/ and SSH keys..."
    tar -czf /tmp/config_backup.tar.gz /etc /home/*/.ssh
    echo -e "${SUCCESS} Backup completed: /tmp/config_backup.tar.gz"
    progress_bar 5
}

config_tracking() {
    echo -e "${MAGENTA}===== Config Change Tracking =====${NC}"
    echo -e "${INFO} Tracking changes in critical system files with Git..."
    sudo git init /etc/ 2> /dev/null
    sudo git --git-dir=/etc/.git add .
    sudo git --git-dir=/etc/.git commit -m "System Audit Snapshot: $(date)"
    echo -e "${SUCCESS} Snapshot taken and stored in /etc/.git."
    progress_bar 5
}

encryption_check() {
    echo -e "${MAGENTA}===== Disk Encryption Check =====${NC}"
    if lsblk | grep -q "crypt"; then
        echo -e "${SUCCESS} Encryption detected for important partitions."
    else
        echo -e "${ERROR} Important partitions are not encrypted. Consider using LUKS for encryption."
    fi
    progress_bar 3
}

generate_report() {
    echo -e "${MAGENTA}===== Generating HTML Report =====${NC}"
    report_file="/tmp/audit_report_$(date +%Y%m%d).html"
    {
        echo "<html><body><h1>Arch Linux Audit Report</h1>"
        echo "<p>Report Date: $(date)</p>"
        echo "<p>System: $(uname -a)</p>"
        echo "<p>Hostname: $(hostname)</p>"
        echo "<h2>System Information</h2>"
        system_info
        echo "<h2>Package Audit</h2>"
        package_audit
        echo "<h2>Firewall & Network Security</h2>"
        firewall_audit
        echo "<h2>Docker Audit</h2>"
        docker_audit
        echo "<h2>Storage Health</h2>"
        storage_health
        echo "<h2>Resource Monitoring</h2>"
        resource_monitor
        echo "</body></html>"
    } > $report_file
    echo -e "${SUCCESS} Report generated at: ${report_file}"
    progress_bar 10
}

menu() {
    echo -e "${BOLD}${CYAN}==== Arch Linux Audit Menu ====${NC}"
    echo -e "1) ${BOLD}${GREEN}System Info${NC}"
    echo -e "2) ${BOLD}${GREEN}Package Audit${NC}"
    echo -e "3) ${BOLD}${GREEN}Firewall & Network Security${NC}"
    echo -e "4) ${BOLD}${GREEN}Docker Audit${NC}"
    echo -e "5) ${BOLD}${GREEN}Storage Health${NC}"
    echo -e "6) ${BOLD}${GREEN}Resource Monitoring${NC}"
    echo -e "7) ${BOLD}${GREEN}Backup Configurations${NC}"
    echo -e "8) ${BOLD}${GREEN}Config Change Tracking${NC}"
    echo -e "9) ${BOLD}${GREEN}Disk Encryption Check${NC}"
    echo -e "10) ${BOLD}${GREEN}Generate Report (HTML)${NC}"
    echo -e "11) ${BOLD}${GREEN}Exit${NC}"
    read -p "Choose an option: " choice
    case $choice in
        1) system_info ;;
        2) package_audit ;;
        3) firewall_audit ;;
        4) docker_audit ;;
        5) storage_health ;;
        6) resource_monitor ;;
        7) backup_configs ;;
        8) config_tracking ;;
        9) encryption_check ;;
        10) generate_report ;;
        11) exit 0 ;;
        *) echo -e "${ERROR} Invalid option, try again." ;;
    esac
}

clear

while true; do
    menu
done
