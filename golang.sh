#!/bin/bash

# 获取所有的Stable版本链接
stable_versions=$(curl -s https://go.dev/dl/?mode=json | grep -E 'version|stable' | awk -F '"' '{print $4}' | tr '\n' ' ')

# 选择最新的版本
latest_version=$(echo $stable_versions | tr ' ' '\n' | grep -E 'go[0-9]+\.[0-9]+\.[0-9]+' | sort -rV | head -n 1)

# 获取最新版本的链接
download_url="https://go.dev/dl/$latest_version.linux-amd64.tar.gz"

# 下载最新版本的安装包
wget $download_url || { echo "下载失败"; exit 1; }

# 检查下载的文件是否存在
if [ ! -f "$latest_version.linux-amd64.tar.gz" ]; then
  echo "下载的文件不存在"
  exit 1
fi

# 解压安装包
sudo tar -C /usr/local -xzf $latest_version.linux-amd64.tar.gz

# 设置环境变量
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc && source ~/.bashrc

# 检查是否成功设置了环境变量
if ! command -v go &> /dev/null; then
  echo "环境变量设置失败"
  exit 1
fi

# 测试安装
go version
