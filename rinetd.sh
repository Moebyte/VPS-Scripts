#!/bin/bash

# 判断是否为 root 用户
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# 判断是否存在 rinetd.conf 文件
if [ ! -f "/etc/rinetd.conf" ]; then
    echo "Creating rinetd.conf..."
    touch /etc/rinetd.conf
    echo "rinetd.conf created successfully."
fi

# 检查是否已经安装过 rinetd
if [ -x "$(command -v rinetd)" ]; then
    installed_version=$(rinetd -v | awk '{print $2}')
    latest_version=$(curl -s https://api.github.com/repos/samhocevar/rinetd/releases/latest | grep name | cut -d '"' -f 4 | cut -d ' ' -f 2)
    if [ "$installed_version" == "$latest_version" ]; then
        echo "rinetd is already installed and up to date."
        exit 0
    else
        echo "Updating rinetd from version $installed_version to $latest_version ..."
        systemctl stop rinetd
        rm -rf /opt/rinetd/
    fi
fi

# 获取最新版本的 rinetd 的下载链接
cd /tmp
download_url=$(curl -s https://api.github.com/repos/samhocevar/rinetd/releases/latest | grep browser_download_url | grep tar.gz | cut -d '"' -f 4)

# 下载 rinetd 的安装包
echo "Downloading rinetd from $download_url ..."
curl -L -O $download_url

# 解压安装包
tar -zxvf rinetd-*.tar.gz
mv rinetd-0.* rinetd
mv rinetd /opt/
cd /opt/rinetd/

# 编译和安装 rinetd
./bootstrap && ./configure && make && make install

# 创建 systemd 服务
cat << EOF > /etc/systemd/system/rinetd.service
[Unit]
Description=rinetd
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/sbin/rinetd -c /etc/rinetd.conf

[Install]
WantedBy=multi-user.target
EOF

# 清理临时文件
rm -rf /tmp/rinetd-*.tar.gz

# 启动 rinetd 服务
systemctl daemon-reload
systemctl start rinetd
systemctl enable rinetd

echo "rinetd installed and started successfully!"
