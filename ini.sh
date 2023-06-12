#!/bin/bash

# Script Name: ini.sh
# Author: MoeByte

# Set variables
BBR_INSTALL_SCRIPT_CHINA='https://lib.ntr.ms/VPS-Scripts/bbr.sh'
BBR_INSTALL_SCRIPT_OTHERS='https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/bbr.sh'
TIMEZONE='Asia/Shanghai'
LOCALE='en_US.UTF-8'

# Install essential packages
apt install -y wget curl vim dnsutils mtr unzip gcc make automake net-tools sudo iptables iftop lsof

# Check if locale is already set to $LOCALE
if ! locale | grep -q "LANG=$LOCALE"; then
    # Update package list
    apt update || exit 1
    # Upgrade packages
    apt upgrade -y || exit 1
    # Install locales
    apt install -y locales || exit 1
    # Generate locale
    echo "$LOCALE UTF-8" >> /etc/locale.gen || exit 1
    locale-gen $LOCALE || exit 1
    update-locale LANG=$LOCALE LANGUAGE=$LOCALE LC_ALL=$LOCALE || exit 1
fi

# Check if TCP congestion control is already set to bbr
if ! sysctl net.ipv4.tcp_available_congestion_control | grep -q "bbr"; then
    # Set timezone
    rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime || exit 1
    # Customize bash prompt
    echo "PS1=\"\[\e[35;1m\][\u@\h \t \w]\\\\$\[\e[0m\]\"" >> ~/.bashrc || exit 1
    # Install BBR
    if curl -m 10 -s https://ipapi.co/json | grep -q 'China'; then
        bash <(wget --no-check-certificate -qO- $BBR_INSTALL_SCRIPT_CHINA) || exit 1
    else
        bash <(wget --no-check-certificate -qO- $BBR_INSTALL_SCRIPT_OTHERS) || exit 1
    fi
fi

echo "Setup completed successfully!"
