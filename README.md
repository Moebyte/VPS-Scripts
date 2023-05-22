# VPS-Scripts
 各类VPS脚本（仅适用于Debian）

网络重装（国内）
```
bash <(wget –-no-check-certificate -qO- "https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/InstallNET.sh") -d 11 -v 64 -p password -port 22 --mirror "https://mirrors.ustc.edu.cn/debian/"
```
Debian配置DNS
```
wget -O - https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/dns-configure.sh | bash
```
安装 locale && BBR
```
wget -O - https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/ini.sh | bash
```
更新镜像源
```
wget -O - https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/apt-sources.sh | bash
```

安装 docker && docker-compose
```
curl -fsSL https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/docker.sh | bash
```
安装rinetd
```
wget -O - https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/rinetd.sh | bash
```
```
wget -O - https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/rinetd-web.sh | bash rinetd-web.sh -p password -port :8080
```
