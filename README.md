# VPS-Scripts
 各类VPS脚本

安装 locale && BBR
```
wget -O - https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/ini.sh | bash
```
更新镜像源
```
wget -O - https://raw.githubusercontent.com/Moebyte/VPS-Scripts/main/ini.sh | bash
```

安装 docker && docker-compose
```
curl -fsSL https://get.docker.com | bash -s docker
```
```
curl -L https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-`uname -m` > ./docker-compose && chmod +x ./docker-compose && mv ./docker-compose /usr/local/bin/docker-compose
```
