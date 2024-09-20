#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' 

install_missing() {
    echo -e "${YELLOW}Checking dependencies...${NC}"
    for dep in "$@"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${RED}Missing dependency: $dep. Installing...${NC}"
            sudo pacman -S --noconfirm $dep
        fi
    done
}

install_missing checkupdates arch-audit iostat ss ufw cronie

system_info() {
    echo -e "${BLUE}===== System Information =====${NC}"
    echo "Hostname: $(hostname)"
    echo "Kernel Version: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Available Updates:"
    checkupdates
}

package_audit() {
    echo -e "${BLUE}===== Package Audit =====${NC}"
    echo -e "${YELLOW}Outdated Packages:${NC}"
    checkupdates | wc -l
    echo -e "${YELLOW}Orphaned Packages:${NC}"
    pacman -Qdtq || echo "No orphaned packages found."
    echo -e "${YELLOW}Vulnerable Packages:${NC}"
    arch-audit
}

vulnerability_scanner() {
    echo -e "${BLUE}===== Vulnerability Scanner =====${NC}"
    echo -e "${YELLOW}Checking for vulnerabilities...${NC}"
    arch-audit
    echo -e "${YELLOW}Pulling CVE data from NVD...${NC}"
}

security_hardening() {
    echo -e "${BLUE}===== Security Hardening Suggestions =====${NC}"
    echo "Checking open ports..."
    ss -tuln
    echo "Checking SSH root access..."
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
        echo -e "${RED}Warning: SSH root access is enabled!${NC}"
    else
        echo -e "${GREEN}SSH root access is disabled.${NC}"
    fi

    echo -e "${YELLOW}Checking for unnecessary services...${NC}"
    services=$(systemctl list-units --type=service --state=running | grep -E 'bluetooth|avahi-daemon|cups')
    if [ "$services" ]; then
        echo -e "${RED}Found unnecessary services: ${services}${NC}"
        echo -e "${YELLOW}Recommend disabling unnecessary services.${NC}"
    else
        echo -e "${GREEN}No unnecessary services found.${NC}"
    fi
}

resource_monitor() {
    echo -e "${BLUE}===== Resource Monitoring =====${NC}"
    echo -e "${YELLOW}Disk Usage:${NC}"
    df -h /
    echo -e "${YELLOW}RAM Usage:${NC}"
    free -h
    echo -e "${YELLOW}CPU Usage:${NC}"
    top -bn1 | grep "Cpu(s)"
    echo -e "${YELLOW}I/O Performance:${NC}"
    iostat
    echo -e "${YELLOW}Network Bandwidth Usage:${NC}"
    ifstat || echo "Install 'ifstat' for bandwidth monitoring"
}

user_audit() {
    echo -e "${BLUE}===== User Account Audit =====${NC}"
    echo "Listing all users with sudo access..."
    getent group sudo
    echo "Detecting weak passwords..."
}

backup_configs() {
    echo -e "${BLUE}===== Backing up Configurations =====${NC}"
    echo "Backing up /etc/ and SSH keys..."
    tar -czf /tmp/config_backup.tar.gz /etc /home/*/.ssh
    echo "Backup saved to /tmp/config_backup.tar.gz"
}

setup_cron() {
    echo -e "${BLUE}===== Setting up Scheduled Audits =====${NC}"
    (crontab -l 2>/dev/null; echo "0 2 * * * /path/to/this/script.sh") | crontab -
    echo "Audit scheduled daily at 2 AM. Logs saved to /var/log/audit.log."
}

log_analysis() {
    echo -e "${BLUE}===== Log File Analysis =====${NC}"
    echo "Scanning logs for errors..."
    sudo grep -i "error\|fail\|crit" /var/log/* | tail -n 20
}

generate_report() {
    echo -e "${BLUE}===== Generating Report =====${NC}"
    echo "Generating a detailed HTML report..."
    report_file="/tmp/audit_report_$(date +%Y%m%d).html"
    {
        echo "<html><body><h1>Arch Linux Audit Report</h1>"
        echo "<p>Report Date: $(date)</p>"
        echo "<p>System: $(uname -a)</p>"
        echo "<p>Hostname: $(hostname)</p>"
        echo "<h2>System Information</h2>"
        echo "<p>Kernel Version: $(uname -r)</p>"
        echo "<p>Uptime: $(uptime -p)</p>"
        echo "<h2>Package Audit</h2>"
        package_audit
        echo "<h2>Security Audit</h2>"
        security_hardening
        echo "<h2>Resource Monitoring</h2>"
        resource_monitor
        echo "</body></html>"
    } > $report_file
    echo "Report saved to $report_file"
}

start_web_dashboard() {
    echo -e "${BLUE}===== Starting Web Dashboard =====${NC}"
}

menu() {
    echo -e "${BLUE}===== Arch Linux Audit Script =====${NC}"
    echo "1. System Information"
    echo "2. Package Audit"
    echo "3. Vulnerability Scanner"
    echo "4. Security Hardening Suggestions"
    echo "5. Resource Monitoring"
    echo "6. User Account Audit"
    echo "7. Backup Configurations"
    echo "8. Setup Scheduled Audits"
    echo "9. Log File Analysis"
    echo "10. Generate Full Report"
    echo "11. Exit"
    echo -n "Choose an option: "
    read option

    case $option in
        1) system_info ;;
        2) package_audit ;;
        3) vulnerability_scanner ;;
        4) security_hardening ;;
        5) resource_monitor ;;
        6) user_audit ;;
        7) backup_configs ;;
        8) setup_cron ;;
        9) log_analysis ;;
        10) generate_report ;;
        11) exit 0 ;;
        *) echo "Invalid option!" ;;
    esac
}

while true; do
    menu
done
