#!/bin/bash

# 检查是否为 root 用户，如果不是则切换到 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo "当前不是root用户，正在切换到sudo模式..."
    exec sudo -i bash "$0" "$@"
    exit
fi

# 更新系统和安装必要的软件包
apt update && apt upgrade -y
apt install -y curl vim wget gnupg dpkg apt-transport-https lsb-release ca-certificates

# 添加 Docker 的 GPG 密钥
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加 Docker 的 APT 源
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker 引擎
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras

# 获取当前用户名并添加到 docker 组
CURRENT_USER=$(logname)
echo "add $CURRENT_USER to docker group"
usermod -aG docker "$CURRENT_USER"

# 配置 Docker
cat > /etc/docker/daemon.json << EOF
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

# 重启 Docker 服务以应用更改
systemctl restart docker

echo "Docker 安装和配置已完成。请重新登录以应用用户组更改。"
