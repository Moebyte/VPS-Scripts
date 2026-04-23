#!/bin/bash

# Script Name: ini.sh
# Author: MoeByte

# Set variables
BBR_INSTALL_SCRIPT_CHINA='https://lib.vb.ms/dns/VPS-Scripts/bbr.sh'
BBR_INSTALL_SCRIPT_OTHERS='https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/bbr.sh'
TIMEZONE='Asia/Shanghai'
LOCALE='en_US.UTF-8'
PS1_BLOCK_START='# >>> vps-scripts-ps1 >>>'
PS1_BLOCK_END='# <<< vps-scripts-ps1 <<<'
PS1_LINE='PS1="\[\e[35;1m\][\u@\h \t \w]\\$\[\e[0m\]"'

# Run command with failure message
run_step() {
    local desc="$1"
    shift
    if ! "$@"; then
        echo "ERROR: ${desc} 失败，脚本退出。"
        exit 1
    fi
}

# Update apt index and install dependencies
run_step "apt update" apt update
run_step "安装依赖软件包" apt install -y wget curl vim dnsutils mtr unzip gcc make automake net-tools sudo iptables iftop lsof locales

# Check if locale is already set to $LOCALE
if ! locale | grep -q "LANG=$LOCALE"; then
    # Upgrade packages
    run_step "apt upgrade" apt upgrade -y

    # Generate locale (write only when missing)
    if ! grep -Fxq "$LOCALE UTF-8" /etc/locale.gen; then
        echo "$LOCALE UTF-8" >> /etc/locale.gen || {
            echo "ERROR: 写入 /etc/locale.gen 失败，脚本退出。"
            exit 1
        }
    fi
    run_step "生成 locale" locale-gen "$LOCALE"
    run_step "更新系统 locale 配置" update-locale LANG="$LOCALE" LANGUAGE="$LOCALE" LC_ALL="$LOCALE"
fi

# Check BBR availability and current enabled value
available_cc="$(sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null || true)"
current_cc="$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || true)"

if echo "$available_cc" | grep -qw "bbr" && [ "$current_cc" = "bbr" ]; then
    echo "BBR 已配置，跳过。"
else
    # Set timezone
    run_step "设置时区" ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

    # Customize bash prompt (write only when missing)
    if ! grep -Fq "$PS1_BLOCK_START" ~/.bashrc; then
        {
            echo "$PS1_BLOCK_START"
            echo "$PS1_LINE"
            echo "$PS1_BLOCK_END"
        } >> ~/.bashrc || {
            echo "ERROR: 写入 ~/.bashrc PS1 配置失败，脚本退出。"
            exit 1
        }
    fi

    # Install BBR
    if curl -m 10 -s https://ipapi.co/json | grep -q 'China'; then
        run_step "安装 BBR（中国线路）" bash <(wget --no-check-certificate -qO- "$BBR_INSTALL_SCRIPT_CHINA")
    else
        run_step "安装 BBR（国际线路）" bash <(wget --no-check-certificate -qO- "$BBR_INSTALL_SCRIPT_OTHERS")
    fi
fi

echo "Setup completed successfully!"
