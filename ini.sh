#!/bin/bash

# Check if locale is already set to en_US.UTF-8
if ! locale | grep -q "LANG=en_US.UTF-8"; then
   
    # Update and upgrade packages
    apt update
    apt upgrade -y

    # Install essential packages
    apt install -y wget curl vim dnsutils mtr unzip gcc make automake net-tools sudo iptables iftop lsof locales
	
    # Generate locale
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
fi

# Check if TCP congestion control is already set to bbr
if ! sysctl net.ipv4.tcp_available_congestion_control | grep -q "bbr"; then

    # Set timezone to Asia/Shanghai
    rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    # Customize bash prompt
    echo "PS1=\"\[\e[35;1m\][\u@\h \t \w]\\\\$\[\e[0m\]\"" >> ~/.bashrc

    # Install BBR
    bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/moeclub/apt/master/bbr/bbr.sh')
fi
