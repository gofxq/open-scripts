#!/bin/bash

# 检查是否以root用户运行
if [ "$(id -u)" != "0" ]; then
    echo "此脚本必须以root身份运行" 1>&2
    exit 1
fi
# 定义下载目录
DOWNLOAD_DIR="/tmp/downloads"
mkdir -p "$DOWNLOAD_DIR"
# 定义下载URL和配置文件路径
DOWNLOAD_URL="https://github.com/fatedier/frp/releases/latest/download"
CONFIG_FILE="/etc/frp/frpc.yml"
SERVICE_FILE="/etc/systemd/system/frpc.service"

# 获取最新版本的下载链接
FRPC_URL=$(curl -sL https://api.github.com/repos/fatedier/frp/releases/latest | grep "browser_download_url.*frp_.*_linux_amd64.tar.gz" | cut -d : -f 2,3 | tr -d \" | head -n 1)
echo %FRPC_URL
# 下载最新版本的frpc
wget -O "$DOWNLOAD_DIR/frpc_latest.tar.gz" $FRPC_URL

# 解压
tar zxvf frpc_latest.tar.gz
FRPC_DIR=$(tar -tzf "$DOWNLOAD_DIR/frpc_latest.tar.gz" | head -1 | cut -f1 -d"/")

# 停止frpc服务如果它已经存在并在运行
if systemctl is-active --quiet frpc; then
    systemctl stop frpc
fi

# 移动frpc到/usr/local/bin
cp $FRPC_DIR/frpc /usr/local/bin/

# 清理文件
rm -rf frpc_latest.tar.gz $FRPC_DIR

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    # 创建配置文件目录
    mkdir -p $(dirname $CONFIG_FILE)

    # 提示用户输入必要的配置信息
    read -p "请输入 FRP 服务器地址: " frp_server_addr
    read -p "请输入 FRP 服务器端口: " frp_server_port
    read -p "请输入 FRP 服务器Token: " frp_server_token
    hostname=$(hostname)
    # 从环境变量或ssh配置文件获取SSH端口
    if [ -n "$SSH_PORT" ]; then
        ssh_port=$SSH_PORT
    else
        ssh_port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')
        # 默认SSH端口是22，如果配置文件中没有指定，则使用22
        ssh_port=${ssh_port:-22}
    fi
    read -p "请输入用于FRP的SSH远程端口: " frp_ssh_port

    # 生成配置文件
    cat <<EOF >$CONFIG_FILE
serverAddr: $frp_server_addr
serverPort: $frp_server_port
auth:
  token: $frp_server_token
proxies:
  - name: ssh.$hostname
    type: tcp
    localIP: 127.0.0.1
    localPort: $ssh_port
    remotePort: $frp_ssh_port
EOF

    echo "配置文件创建成功，位于 $CONFIG_FILE"
else
    echo "配置文件已存在，跳过创建步骤。"
fi

# 创建或更新 Systemd 服务文件
cat <<EOF >$SERVICE_FILE
[Unit]
Description=frp client service
After = network.target syslog.target
Wants = network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/local/bin/frpc -c $CONFIG_FILE

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd，启用并启动frpc服务
systemctl daemon-reload
systemctl enable frpc
systemctl start frpc

echo "frpc 安装或更新并启动完成！"
