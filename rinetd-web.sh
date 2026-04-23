#!/bin/bash

# Script Name: rinetd.sh
# Author: MoeByte

# 默认参数值
password=""
port=""

validate_ip_port() {
    local ip_port="$1"
    local ip port_part

    if [[ ! $ip_port =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{1,5}$ ]]; then
        return 1
    fi

    ip="${ip_port%:*}"
    port_part="${ip_port##*:}"

    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
        if ((octet < 0 || octet > 255)); then
            return 1
        fi
    done

    if ((port_part < 1 || port_part > 65535)); then
        return 1
    fi

    return 0
}

# 解析命令行参数
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -p|--password)
        if [[ -z "$2" || "$2" == -* ]]; then
            echo "Error: Password cannot be empty. Please use -p <password>."
            exit 1
        fi
        password="$2"
        shift
        shift
        ;;
        -port|--port)
        if [[ -z "$2" || "$2" == -* ]]; then
            echo "Error: Port cannot be empty. Please use -port <IP:PORT>."
            exit 1
        fi
        # 验证格式与范围
        if validate_ip_port "$2"; then
            port="$2"
        else
            echo "Error: Invalid port '$2'. Please use IP:PORT format and ensure PORT is in range 1-65535."
            exit 1
        fi
        shift
        shift
        ;;
        *)
        echo "Unknown option $1"
        exit 1
        ;;
    esac
done

# 如果没有传入参数，则使用默认端口值
if [[ -z $password ]]; then
    echo "Error: Password cannot be empty. Please use -p <password>."
    exit 1
fi
if [[ -z $port ]]; then
    port="0.0.0.0:8080"
fi

# 下载 rinetd-web 并移动至 /opt/rinetd-web
curl -sSL "https://github.com/Moebyte/VPS-Scripts/raw/main/rinetd-web" -o /opt/rinetd/rinetd-web
chmod +x /opt/rinetd/rinetd-web

# 创建 systemd 服务
cat <<EOF > /etc/systemd/system/rinetd-web.service
[Unit]
Description=rinetd-web
After=syslog.target network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/rinetd
ExecStart=/opt/rinetd/rinetd-web -p ${password} -port ${port}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
systemctl daemon-reload
systemctl enable rinetd-web
systemctl start rinetd-web
