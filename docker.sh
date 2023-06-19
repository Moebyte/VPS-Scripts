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
        DOCKER_MIRROR='{"registry-mirrors": ["https://dockerproxy.com"]}'
    else
        MIRROR="https://download.docker.com/linux/debian"
        DOCKER_MIRROR='{}'
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
echo "$DOCKER_MIRROR" > /etc/docker/daemon.json

# Restart Docker service
systemctl restart docker
