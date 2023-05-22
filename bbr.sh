#!/bin/bash

FORCE="$1"
REBOOT="${2:-1}"

if [[ "$FORCE" == "-f" && ! -f "/lib/modules/$(uname -r)/kernel/net/ipv4/tcp_bbr.ko" ]]; then
    printf "This Kernel Not Support BBR by Default.\n"
    exit 1
else
    printf "1\n"
fi

apt update
printf "gc,make" | debconf-communicate
apt install -y gcc make

kernel=$(uname -r | sed -E "s/-generic-/-headers-$(uname -r | sed -E 's/-.*//')/")
if [ ! -d "/usr/src/$kernel" ]; then
    printf "No Found Kernel Version.\n"
    exit 1
fi

printf 'Building %s ...\n' "$kernel"
printf "net.ipv4.tcp_congestion_control=$(echo "$kernel" | awk -F- '{print $1}')\n" | tee -a /etc/sysctl.conf /etc/sysctl.d/"$kernel".conf

printf 'Setting: limits.conf\n'
LIMIT='262144'
if [ -f /etc/security/limits.conf ]; then
    sed -i '/^(\*|root)[[:space:]]*(hard|soft)[[:space:]]*(nofile|memlock)/d' /etc/security/limits.conf
    printf "*\thard\tmemlock\t%s\n*\tsoft\tmemlock\t%s\nroot\thard\tmemlock\t%s\nroot\tsoft\tmemlock\t%s\n*\thard\tnofile\t%s\n*\tsoft\tnofile\t%s\nroot\thard\tnofile\t%s\nroot\tsoft\tnofile\t%s\n\n" "$LIMIT" "$LIMIT" "$LIMIT" "$LIMIT" "$LIMIT" "$LIMIT" "$LIMIT" "$LIMIT" >>/etc/security/limits.conf
fi

if [ -f /etc/systemd/system.conf ]; then
    sed -i 's/#\?DefaultLimitNOFILE=.*/DefaultLimitNOFILE=262144/' /etc/systemd/system.conf
fi

printf 'Setting: sysctl.conf\n'
cat <<EOF >/etc/sysctl.conf
fs.file-max = 104857600
fs.nr_open = 1048576
vm.overcommit_memory = 1
vm.swappiness = 10
net.core.somaxconn = 65535
net.core.optmem_max = 1048576
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.netdev_max_backlog = 65536
net.ipv4.tcp_mem = 2097152 8388608 16777216 
net.ipv4.tcp_rmem = 16384 524288 16777216
net.ipv4.tcp_wmem = 16384 524288 16777216
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 16
net.ipv4.tcp_keepalive_intvl = 32
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 900
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 8
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.ip_forward = 1

net.ipv4.icmp_echo_ignore_all = 1
net.ipv6.conf.all.disable_ipv6 = 1

net.ipv4.tcp_fastopen = 0
net.ipv4.tcp_fack = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_ecn_fallback = 1

net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
EOF

if [ "$REBOOT" -eq "1" ]; then
    /sbin/reboot
fi
