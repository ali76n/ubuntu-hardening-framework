# Ubuntu Enterprise Hardening Framework

A modular, automated Ubuntu server hardening framework built with **Ansible** and **Python**.

The project is designed to audit, secure, harden, and report the security posture of Ubuntu servers using repeatable and modular automation.

---

## Features

* Ubuntu OS and version validation
* Preflight security checks
* SSH hardening
* Firewall configuration with UFW
* Fail2Ban protection
* Auditd configuration
* Kernel hardening
* Sysctl security tuning
* User and privilege management
* Password policy enforcement
* System logging hardening
* AppArmor configuration
* Automatic security updates
* File permission hardening
* Unnecessary service management
* Cron security checks
* AIDE file integrity monitoring
* Compliance checks
* Automated security reports

---

## Architecture

```text
                         ┌──────────────────────────────┐
                         │      Ansible Controller       │
                         │                              │
                         │  Ubuntu Hardening Framework   │
                         └───────────────┬──────────────┘
                                         │
                         SSH + Ansible   │
                                         ▼
                    ┌────────────────────────────────┐
                    │        Ubuntu Target Server     │
                    │                                │
                    │  Preflight                     │
                    │  SSH Hardening                  │
                    │  Firewall                      │
                    │  Auditd                        │
                    │  Sysctl                        │
                    │  AppArmor                      │
                    │  AIDE                          │
                    │  Logging                       │
                    └────────────────────────────────┘
```

---

## Project Structure

```text
ubuntu-hardening-framework/
│
├── ansible.cfg
├── requirements.yml
├── site.yml
├── README.md
│
├── inventories/
│   └── production/
│       └── hosts.yml
│
├── group_vars/
│   └── all.yml
│
├── roles/
│   ├── preflight/
│   ├── common/
│   ├── ssh/
│   ├── firewall/
│   ├── fail2ban/
│   ├── auditd/
│   ├── sysctl/
│   ├── kernel/
│   ├── users/
│   ├── password_policy/
│   ├── logging/
│   ├── apparmor/
│   ├── unattended_upgrades/
│   ├── file_permissions/
│   ├── services/
│   ├── cron/
│   ├── aide/
│   └── compliance/
│
├── scripts/
│   ├── bootstrap-controller.sh
│   ├── run-hardening.sh
│   └── generate-report.sh
│
└── reports/
```

---

# Requirements

## Controller

The Ansible Controller requires:

* Ubuntu/Debian Linux
* Python 3
* Ansible Core
* OpenSSH Client
* Git

Install Ansible:

```bash
sudo apt update
sudo apt install -y ansible git openssh-client python3 python3-pip
```

Verify:

```bash
ansible --version
python3 --version
```

---

## Target Server

Supported operating systems:

* Ubuntu 22.04 LTS
* Ubuntu 24.04 LTS
* Ubuntu 26.04

The target server must have:

* SSH server
* Python 3
* A user with sudo privileges
* Network connectivity from the Ansible Controller

---

# Installation

Clone the project:

```bash
git clone https://github.com/YOUR_USERNAME/ubuntu-hardening-framework.git
cd ubuntu-hardening-framework
```

Install Ansible requirements:

```bash
ansible-galaxy collection install -r requirements.yml
```

---

# SSH Configuration

The recommended architecture is:

```text
Ansible Controller
        │
        │ SSH Key Authentication
        ▼
Ubuntu Target Server
```

Generate an SSH key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

Copy the public key to the target:

```bash
ssh-copy-id ali@192.168.31.131
```

Test the connection:

```bash
ssh ali@192.168.31.131
```

The connection should work without requiring a password.

---

# Inventory Configuration

Edit:

```text
inventories/production/hosts.yml
```

Example:

```yaml
---
all:
  children:
    ubuntu_servers:
      hosts:
        server01:
          ansible_host: 192.168.31.131
          ansible_user: ali
          ansible_ssh_private_key_file: /root/.ssh/id_ed25519

      vars:
        ansible_become: true
        ansible_become_method: sudo
        ansible_become_user: root
```

For multiple servers:

```yaml
---
all:
  children:
    ubuntu_servers:
      hosts:
        server01:
          ansible_host: 192.168.31.131
          ansible_user: ali

        server02:
          ansible_host: 192.168.31.132
          ansible_user: ubuntu

        server03:
          ansible_host: 192.168.31.133
          ansible_user: ubuntu

      vars:
        ansible_become: true
```

---

# Test Connectivity

Test the Ansible connection:

```bash
ansible \
-i inventories/production/hosts.yml \
ubuntu_servers \
-m ping
```

Expected output:

```text
server01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Test root privilege:

```bash
ansible \
-i inventories/production/hosts.yml \
ubuntu_servers \
-m command \
-a "whoami"
```

Expected output:

```text
root
```

---

# Preflight Checks

The Preflight role validates the target server before any hardening changes are applied.

Run:

```bash
ansible-playbook \
-i inventories/production/hosts.yml \
site.yml \
--tags preflight
```

The Preflight phase checks:

* Operating system
* Ubuntu version
* Kernel version
* CPU architecture
* Python availability
* Memory
* Disk space
* Network configuration
* Current users
* SSH configuration
* Existing firewall
* Running services
* Package manager status
* Reboot requirement

---

# Run Hardening

Run the complete hardening framework:

```bash
ansible-playbook \
-i inventories/production/hosts.yml \
site.yml
```

Run against a specific server:

```bash
ansible-playbook \
-i inventories/production/hosts.yml \
site.yml \
--limit server01
```

Run in check mode:

```bash
ansible-playbook \
-i inventories/production/hosts.yml \
site.yml \
--check
```

Run with detailed output:

```bash
ansible-playbook \
-i inventories/production/hosts.yml \
site.yml \
-vvv
```

---

# Hardening Modules

## SSH

The SSH role hardens:

* SSH protocol configuration
* Root login
* Password authentication
* Empty passwords
* X11 forwarding
* TCP forwarding
* Login grace time
* Maximum authentication attempts
* Idle session timeout

Example controls:

```text
PermitRootLogin no
MaxAuthTries 3
X11Forwarding no
PermitEmptyPasswords no
```

---

## Firewall

The firewall role configures:

* Default deny incoming traffic
* Default allow outgoing traffic
* SSH access
* Custom application ports

Example:

```text
Incoming: DENY
Outgoing: ALLOW
SSH: ALLOW
```

Always verify SSH access before applying firewall rules remotely.

---

## Fail2Ban

Fail2Ban protects services against brute-force attacks.

Protected services may include:

* SSH
* Web servers
* Authentication services

---

## Auditd

Auditd monitors:

* Authentication events
* Privilege escalation
* User changes
* Sudo activity
* Sensitive file access
* Kernel module changes

---

## Sysctl

Kernel networking and security parameters are hardened.

Examples:

```text
IP forwarding
ICMP redirects
Source routing
SYN cookies
Reverse path filtering
Kernel pointer restrictions
Core dump restrictions
```

---

## AppArmor

AppArmor profiles are checked and enforced where applicable.

The role verifies:

```bash
sudo aa-status
```

---

## AIDE

AIDE provides file integrity monitoring.

It can detect changes to:

* `/etc`
* `/bin`
* `/sbin`
* `/usr/bin`
* `/usr/sbin`

---

# Reports

Reports are generated in:

```text
reports/
```

Generate a report:

```bash
./scripts/generate-report.sh
```

Example:

```text
reports/
├── hardening-report-2026-07-17.txt
├── compliance-report-2026-07-17.json
└── system-inventory-2026-07-17.json
```

---

# Security Model

This project follows a defense-in-depth model:

```text
                 ┌───────────────────────┐
                 │     SSH Hardening      │
                 └───────────┬───────────┘
                             │
                 ┌───────────▼───────────┐
                 │        Firewall        │
                 └───────────┬───────────┘
                             │
                 ┌───────────▼───────────┐
                 │        Fail2Ban        │
                 └───────────┬───────────┘
                             │
                 ┌───────────▼───────────┐
                 │        Auditd          │
                 └───────────┬───────────┘
                             │
                 ┌───────────▼───────────┐
                 │    Kernel / Sysctl     │
                 └───────────┬───────────┘
                             │
                 ┌───────────▼───────────┐
                 │      AppArmor          │
                 └───────────┬───────────┘
                             │
                 ┌───────────▼───────────┐
                 │   File Integrity       │
                 │       AIDE             │
                 └───────────────────────┘
```

---

# Important Warning

Hardening can affect:

* SSH access
* Network connectivity
* Running applications
* System services
* Kernel behavior
* User permissions

Before running the complete framework on production servers:

1. Create a backup.
2. Verify SSH access.
3. Test in a lab environment.
4. Run the Preflight role.
5. Run Ansible in check mode.
6. Apply changes gradually.
7. Keep console access available.

---

# Development Workflow

Recommended workflow:

```text
1. Add server to inventory
          │
          ▼
2. Test SSH
          │
          ▼
3. Test Ansible ping
          │
          ▼
4. Run Preflight
          │
          ▼
5. Run Check Mode
          │
          ▼
6. Apply Hardening
          │
          ▼
7. Run Compliance
          │
          ▼
8. Generate Report
```

---

# Roadmap

* [ ] CIS Ubuntu Benchmark mapping
* [ ] NIST 800-53 mapping
* [ ] STIG compliance checks
* [ ] HTML reports
* [ ] JSON compliance output
* [ ] Automatic rollback
* [ ] Backup before hardening
* [ ] Multi-distribution support
* [ ] CI/CD pipeline
* [ ] GitHub Actions
* [ ] Docker testing
* [ ] Molecule tests
* [ ] Testcontainers integration

---

# License

This project is intended for educational, testing, automation, and defensive security purposes.

Always test security changes before deploying them to production systems.
