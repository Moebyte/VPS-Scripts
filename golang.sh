#!/bin/bash

# 获取所有的Stable版本链接
stable_versions=$(curl -s https://golang.org/dl/?mode=json | grep -E 'version|stable' | awk -F '"' '{print $4}' | tr '\n' ' ')

# 选择最新的版本
latest_version=$(echo $stable_versions | tr ' ' '\n' | grep -E 'go[0-9]+\.[0-9]+\.[0-9]+' | sort -rV | head -n 1)

# 获取最新版本的链接
download_url="https://golang.org/dl/$latest_version.linux-amd64.tar.gz"

# 下载最新版本的安装包
wget $download_url

# 解压安装包
tar -C /usr/local -xzf $latest_version.linux-amd64.tar.gz

# 设置环境变量
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

# 测试安装
go version
