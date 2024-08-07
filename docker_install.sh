#!/bin/bash

# 确保脚本以 root 权限运行
if [ "$(id -u)" != "0" ]; then
    echo "不是 root 用户，将切换至 root 用户执行..."
    exec sudo -i bash "$0" "$@"
fi

# 退出脚本如果任何命令执行失败
set -e

# 更新系统软件包并安装必要的工具
apt-get update && apt-get upgrade -y
apt-get install -y curl gnupg lsb-release

# 添加 Docker 的官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置 Docker APT 源
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# 安装 Docker CE, CLI 和其他必要的组件
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras

# 配置 Docker 守护进程的日志和网络设置
cat > /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "20m",
        "max-file": "3"
    },
    "ipv6": true,
    "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
    "experimental": true,
    "ip6tables": true
}
EOF

# 重启 Docker 服务来应用配置更改
systemctl restart docker

# 添加当前用户到 Docker 用户组
CURRENT_USER=$(logname)
usermod -aG docker "$CURRENT_USER"

# 提示用户重新登录以应用组更改
echo "Docker 安装并配置已完成。请重新登录以使组更改生效。"
