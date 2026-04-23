#!/bin/bash

# Script Name: docker.sh
# Author: MoeByte

# Check if user has root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Function to check if Docker is already installed
check_docker_installed() {
    if docker --version > /dev/null 2>&1; then
        echo "Docker is already installed. Exiting."
        exit
    fi
}

# Function to check IP address and set mirror
set_mirror() {
    if curl -m 10 -s https://ipapi.co/json | grep 'China'; then
        MIRROR="https://mirrors.ustc.edu.cn/docker-ce/linux/debian"
        DOCKER_REGISTRY_MIRRORS='["https://dockerproxy.com"]'
    else
        MIRROR="https://download.docker.com/linux/debian"
        DOCKER_REGISTRY_MIRRORS='[]'
    fi
}

# Check if Docker is already installed
check_docker_installed

# Remove old versions of Docker
apt-get remove docker docker-engine docker.io containerd runc

# Install required packages
apt-get update
apt-get install -y ca-certificates curl gnupg

# Add Docker's GPG key
install -m 0755 -d /etc/apt/keyrings
set_mirror
curl -fsSL "${MIRROR}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker's repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] ${MIRROR} $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker and related packages
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Configure Docker mirror
install -d -m 0755 /etc/docker
DAEMON_JSON="/etc/docker/daemon.json"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

if [ ! -f "$DAEMON_JSON" ]; then
    echo "{}" > "$DAEMON_JSON"
else
    cp -a "$DAEMON_JSON" "${DAEMON_JSON}.bak.${TIMESTAMP}"
fi

if command -v jq >/dev/null 2>&1; then
    TMP_JSON="$(mktemp)"
    if ! jq --argjson mirrors "$DOCKER_REGISTRY_MIRRORS" '.["registry-mirrors"] = $mirrors' "$DAEMON_JSON" > "$TMP_JSON"; then
        echo "ERROR: Failed to update $DAEMON_JSON with jq."
        rm -f "$TMP_JSON"
        exit 1
    fi
    mv "$TMP_JSON" "$DAEMON_JSON"
else
    if [ -f "$DAEMON_JSON" ]; then
        cp -a "$DAEMON_JSON" "${DAEMON_JSON}.bak.${TIMESTAMP}.nojq"
    fi
    cat > "$DAEMON_JSON" <<EOF
{
  "registry-mirrors": $DOCKER_REGISTRY_MIRRORS
}
EOF
fi

# Restart Docker service
if ! systemctl daemon-reload; then
    echo "ERROR: systemctl daemon-reload failed."
    systemctl status docker --no-pager -l || true
    journalctl -u docker --no-pager -n 50 || true
    exit 1
fi

if ! systemctl restart docker; then
    echo "ERROR: Failed to restart docker service."
    systemctl status docker --no-pager -l || true
    journalctl -u docker --no-pager -n 50 || true
    exit 1
fi
