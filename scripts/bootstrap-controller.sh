#!/usr/bin/env bash

set -Eeuo pipefail

log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

log "Updating APT cache..."

apt-get update

log "Installing controller dependencies..."

apt-get install -y \
    ansible \
    python3 \
    python3-pip \
    python3-venv \
    git \
    openssh-client \
    jq \
    curl \
    rsync

log "Installing Ansible collections..."

ansible-galaxy collection install \
    ansible.posix \
    community.general

log "Checking Ansible..."

ansible --version

log "Controller bootstrap completed successfully."
