#!/bin/bash

# Script Name: apt-sources.sh
# Author: MoeByte

set -euo pipefail

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
MODIFIED_FILES=()

SOURCES_LIST="/etc/apt/sources.list"
DEBIAN_SOURCES="/etc/apt/sources.list.d/debian.sources"

replace_in_sources_list=false
replace_in_debian_sources=false

if [[ -f "$SOURCES_LIST" ]] && grep -Eq 'deb\.debian\.org|security\.debian\.org' "$SOURCES_LIST"; then
  replace_in_sources_list=true
fi

if [[ -f "$DEBIAN_SOURCES" ]]; then
  replace_in_debian_sources=true
fi

if [[ "$replace_in_sources_list" == false && "$replace_in_debian_sources" == false ]]; then
  echo "未命中可修改的 Debian 源文件：$SOURCES_LIST 或 $DEBIAN_SOURCES，已退出。"
  exit 1
fi

if [[ "$replace_in_sources_list" == true ]]; then
  backup_file="${SOURCES_LIST}.bak.${TIMESTAMP}"
  cp "$SOURCES_LIST" "$backup_file"

  sed -i \
    -e 's|https\?://deb\.debian\.org/debian|https://mirrors.ustc.edu.cn/debian|g' \
    -e 's|https\?://security\.debian\.org/debian-security|https://mirrors.ustc.edu.cn/debian-security|g' \
    "$SOURCES_LIST"

  MODIFIED_FILES+=("$SOURCES_LIST")
fi

if [[ "$replace_in_debian_sources" == true ]]; then
  backup_file="${DEBIAN_SOURCES}.bak.${TIMESTAMP}"
  cp "$DEBIAN_SOURCES" "$backup_file"

  awk '
    /^URIs:[[:space:]]*/ {
      if ($0 ~ /debian-security/) {
        print "URIs: https://mirrors.ustc.edu.cn/debian-security"
      } else {
        print "URIs: https://mirrors.ustc.edu.cn/debian"
      }
      next
    }
    { print }
  ' "$DEBIAN_SOURCES" > "${DEBIAN_SOURCES}.tmp.${TIMESTAMP}"

  mv "${DEBIAN_SOURCES}.tmp.${TIMESTAMP}" "$DEBIAN_SOURCES"
  MODIFIED_FILES+=("$DEBIAN_SOURCES")
fi

echo "已修改文件列表："
for file in "${MODIFIED_FILES[@]}"; do
  echo "- $file"
done

apt update -y
