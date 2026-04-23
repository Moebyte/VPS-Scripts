#!/bin/bash

# Script Name: golang.sh
# Author: MoeByte

set -euo pipefail

# 统一权限模型：该脚本需要 root 权限安装到 /usr/local
if [ "${EUID}" -ne 0 ]; then
  echo "请使用 root 运行此脚本（例如：sudo bash golang.sh）"
  exit 1
fi

# 判断IP地址是否为中国
if curl -m 10 -s https://ipapi.co/json | grep -q 'China'; then
  # 中国用户使用 golang.google.cn/dl/
  base_url='https://golang.google.cn/dl/'
  go_proxy='https://goproxy.cn'
else
  # 非中国用户使用 go.dev/dl/
  base_url='https://go.dev/dl/'
  go_proxy=''
fi

# 依赖检测：优先 jq；若没有则尝试安装，失败时降级到 python3 解析 JSON
ensure_jq() {
  if command -v jq >/dev/null 2>&1; then
    return 0
  fi

  echo "未检测到 jq，尝试自动安装..."
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y && apt-get install -y jq && return 0
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y jq && return 0
  elif command -v yum >/dev/null 2>&1; then
    yum install -y jq && return 0
  elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache jq && return 0
  fi

  return 1
}

json_payload="$(curl -fsSL "$base_url?mode=json")"

if ensure_jq; then
  latest_version="$(printf '%s' "$json_payload" | jq -r '[.[] | select(.stable == true) | .version] | max')"
  file_name="$(printf '%s' "$json_payload" | jq -r --arg ver "$latest_version" '.[] | select(.version == $ver) | .files[] | select(.os == "linux" and .arch == "amd64" and .kind == "archive") | .filename' | head -n1)"
  file_sha256="$(printf '%s' "$json_payload" | jq -r --arg ver "$latest_version" '.[] | select(.version == $ver) | .files[] | select(.os == "linux" and .arch == "amd64" and .kind == "archive") | .sha256' | head -n1)"
else
  echo "jq 安装失败，降级使用 python3 进行 JSON 解析..."
  if ! command -v python3 >/dev/null 2>&1; then
    echo "缺少 python3，无法可靠解析 JSON。"
    exit 1
  fi
  latest_version="$(printf '%s' "$json_payload" | python3 -c 'import json,sys,re;data=json.load(sys.stdin);vs=[x["version"] for x in data if x.get("stable") and re.fullmatch(r"go\d+\.\d+\.\d+", x.get("version",""))];print(sorted(vs, key=lambda s:[int(n) for n in s[2:].split(".")])[-1])')"
  read -r file_name file_sha256 <<<"$(printf '%s' "$json_payload" | python3 -c 'import json,sys;data=json.load(sys.stdin);import os;ver=os.environ["GO_VER"];f=next((fi for x in data if x.get("version")==ver for fi in x.get("files",[]) if fi.get("os")=="linux" and fi.get("arch")=="amd64" and fi.get("kind")=="archive"),None);print((f or {}).get("filename",""),(f or {}).get("sha256",""))' GO_VER="$latest_version")"
fi

if [ -z "${latest_version:-}" ] || [ "$latest_version" = "null" ]; then
  echo "无法获取最新稳定版 Go 版本号。"
  exit 1
fi

if [ -z "${file_name:-}" ] || [ "$file_name" = "null" ]; then
  echo "未找到 $latest_version 对应的 linux-amd64 安装包。"
  exit 1
fi

# 检查最新版本是否已经安装
if command -v go >/dev/null 2>&1 && go version | grep -q "$latest_version"; then
  echo "已经安装了最新的 Go 版本"
  exit 0
fi

# 下载最新版本的安装包
download_url="$base_url$file_name"
download_path="/tmp/$file_name"
if ! wget -O "$download_path" "$download_url"; then
  echo "下载失败"
  exit 1
fi

# 检查下载的文件是否存在且非空（完整性最低要求）
if [ ! -s "$download_path" ]; then
  echo "下载的文件不存在"
  exit 1
fi

# 校验 SHA256（如果上游提供）
if [ -n "${file_sha256:-}" ] && [ "$file_sha256" != "null" ]; then
  current_sha256="$(sha256sum "$download_path" | awk '{print $1}')"
  if [ "$current_sha256" != "$file_sha256" ]; then
    echo "SHA256 校验失败，文件可能损坏。"
    exit 1
  fi
fi

# 解压安装包
rm -rf /usr/local/go
tar -C /usr/local -xzf "$download_path"

# 更新环境变量
path_marker="# >>> golang.sh PATH >>>"
if ! grep -qxF "$path_marker" /root/.bashrc; then
  {
    echo ""
    echo "$path_marker"
    echo 'export PATH="$PATH:/usr/local/go/bin"'
    echo "# <<< golang.sh PATH <<<"
  } >> /root/.bashrc
fi

# 检查是否成功设置了环境变量
export PATH="$PATH:/usr/local/go/bin"
if ! command -v go >/dev/null 2>&1; then
  echo "环境变量设置失败"
  exit 1
fi

# 测试安装
go version

# 如果是中国用户，设置环境变量
if [ "$go_proxy" != "" ]; then
  go env -w GO111MODULE=on
  go env -w GOPROXY="$go_proxy,direct"
fi

# 删除下载的压缩包
rm -f "$download_path"
