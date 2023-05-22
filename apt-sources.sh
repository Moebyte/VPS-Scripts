#!/bin/bash

# Script Name: apt-sources.sh
# Author: MoeByte

# 备份原有的 sources.list 文件
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 替换为 USTC 镜像源
sed -i 's/http:\/\/deb.debian.org\/debian/https:\/\/mirrors.ustc.edu.cn\/debian/g' /etc/apt/sources.list
sed -i 's/http:\/\/security.debian.org\/debian-security/https:\/\/mirrors.ustc.edu.cn\/debian-security/g' /etc/apt/sources.list

# 更新镜像源
apt update -y
