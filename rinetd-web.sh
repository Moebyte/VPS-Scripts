#!/bin/bash

# Script Name: rinetd.sh
# Author: MoeByte

# 默认参数值
password=""
port=""

# 解析命令行参数
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -p|--password)
        password="$2"
        shift
        shift
        ;;
        -port|--port)
        # 验证格式是否正确
        if [[ $2 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+$ ]]; then
            port="$2"
        else
            echo "Invalid port format. Please use IP:PORT format."
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

# 如果没有传入参数，则使用默认值
if [[ -z $password ]]; then
    password="password"
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
ExecStart=/opt/rinetd/rinetd-web -p pass -port :8080
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
systemctl daemon-reload
systemctl enable rinetd-web
systemctl start rinetd-web
