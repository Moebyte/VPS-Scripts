# VPS-Scripts
 各类VPS脚本（仅适用于Debian）

网络重装（国内）
```
bash <(wget –-no-check-certificate -qO- "https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/InstallNET.sh") -d 11 -v 64 -p password -port 22 --mirror "https://mirrors.ustc.edu.cn/debian/"
```
Debian配置DNS（国外）
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
curl -fsSL https://get.docker.com | bash -s docker
```
```
curl -L https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-`uname -m` > ./docker-compose && chmod +x ./docker-compose && mv ./docker-compose /usr/local/bin/docker-compose
```
