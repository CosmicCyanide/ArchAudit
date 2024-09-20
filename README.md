Arch Linux Audit Script
Overview

The Arch Linux Audit Script is a comprehensive tool designed to audit and monitor your Arch Linux system. It provides functionalities such as package audits, system information retrieval, network security checks, Docker audits, and more. This script helps ensure optimal system performance and security with minimal effort.
Features

    System Information Retrieval
    Package Audits (Outdated, Orphaned, Vulnerable)
    Firewall and Network Security Checks
    Docker and Container Audits
    Storage Health Monitoring
    Resource Usage Monitoring
    Configuration Backups
    Change Tracking for Critical Files
    Disk Encryption Status Check
    HTML Report Generation

Prerequisites

Before running the script, ensure that you have the following packages installed on your Arch Linux system:
Required Packages

    checkupdates: To check for available updates.


```sudo pacman -Syu```

arch-audit: To scan for vulnerabilities in installed packages.


```sudo pacman -S arch-audit```

sysstat: Provides sar for system performance statistics.


```sudo pacman -S sysstat```

dstat: A versatile resource statistics tool.

```sudo pacman -S dstat```

ufw: Uncomplicated Firewall for managing firewall rules.

```sudo pacman -S ufw```

cronie: A cron daemon for scheduling tasks.

```sudo pacman -S cronie```

docker: Containerization platform for managing containers.

```sudo pacman -S docker```

smartmontools: To monitor SSD/HDD health.

```sudo pacman -S smartmontools```

git: For version control and change tracking.

```sudo pacman -S git```

nload: Network traffic monitoring tool.

    sudo pacman -S nload

Installation

```git clone https://github.com/yourusername/arch-linux-audit-script.git```
```cd arch-linux-audit-script```

Make the script executable:

    chmod +x audit_script.sh

Usage

To run the audit script, execute the following command:

```./audit_script.sh```

You will be presented with a menu of options. Choose the corresponding number for the audit or check you wish to perform.
Features Breakdown


    System Info: Retrieves and displays system hostname, kernel version, uptime, and available updates.
    Package Audit: Checks for outdated, orphaned, and vulnerable packages.
    Firewall & Network Security: Checks firewall status and active ports, and monitors network traffic.
    Docker Audit: Lists running Docker containers and cleans up unused images.
    Storage Health: Monitors SSD/HDD health using smartctl.
    Resource Monitoring: Provides real-time resource usage statistics.
    Backup Configurations: Backs up critical configuration files.
    Config Change Tracking: Tracks changes in system configuration files using Git.
    Disk Encryption Check: Verifies if important partitions are encrypted.
    Generate Report: Creates an HTML report summarizing the audit findings.

Contributing

Contributions are welcome! If you have suggestions or improvements, feel free to open an issue or submit a pull request.
License

This project is licensed under the MIT License. See the LICENSE file for details.
