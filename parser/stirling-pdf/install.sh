#!/bin/bash

port_expose='18000'
CONTAINER_NAME='stirling-pdf'

# 检查Docker是否安装并运行
if ! command -v docker &> /dev/null; then
    echo "错误：Docker未安装或未在PATH中找到。"
    echo '若您的Linux系统具备外网访问能力，请使用如下命令安装docker。'
    echo 'bash <(curl -sSL https://linuxmirrors.cn/docker.sh)'
    exit 1
fi

# 检查Docker服务是否运行
if ! docker info &> /dev/null; then
    echo "错误：Docker服务未运行。"
    exit 1
fi

# 检查是否存在名为easyrag的Docker Bridge网络,若不存在则创建。
network_name="easyrag"
network_exists=$(docker network ls --filter "name=${network_name}" --format '{{.Name}}')

if [[ "$network_exists" == "$network_name" ]]; then
    echo "Docker Bridge网络 '${network_name}' 存在。"
    # 可选：显示网络详细信息
    # docker network inspect "${network_name}"
else
    echo "Docker Bridge网络 '${network_name}' 不存在。"
    docker network create easyrag
fi

if [ -n "$(docker ps -aq --filter "name=^${CONTAINER_NAME}$")" ]; then
    echo "✅ 容器 '$CONTAINER_NAME' 已存在"
    echo "容器状态：$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME")"
else
    echo "容器 '$CONTAINER_NAME' 不存在，正在创建..."
    docker run -d --name=stirling-pdf --network=easyrag --workdir=/ -p ${port_expose}:8080 --restart=always  frooodle/s-pdf:0.46.2 sh -c 'java -Dfile.encoding=UTF-8 -jar /app.jar & /opt/venv/bin/unoserver --port 2003 --interface 127.0.0.1'
    echo "容器创建完成"
fi