#!/bin/bash

# 使用命令行参数或默认值
TOKEN=${1:-$(openssl rand -hex 12)}
WEB_PASSWORD=${2:-$(openssl rand -hex 12)}

# 定义配置文件路径和日志目录
DEFAULT_BIND_PORT=11000

CONFIG_FILE="/etc/frp/frps.yml"
LOG_DIR="/tmp/frps/logs_server.log"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    # 创建配置文件目录
    mkdir -p $(dirname $CONFIG_FILE)
    mkdir -p $(dirname $LOG_DIR)

    # 提示用户输入token，如果为空则生成随机token
    read -p "请输入 FRP 服务器Token (留空将自动生成): " 
    if [ -z "$RANDOM_TOKEN" ]; then
        RANDOM_TOKEN=$(openssl rand -hex 12)
    fi

    # 提示用户输入web密码，如果为空则生成随机密码
    read -p "请输入 FRP Web 管理界面密码 (留空将自动生成): " 
    if [ -z "$RANDOM_WEB_PASSWORD" ]; then
        RANDOM_WEB_PASSWORD=$(openssl rand -hex 12)
    fi

    # 默认绑定端口

    # 生成配置文件
    cat <<EOF >$CONFIG_FILE
bindPort: $DEFAULT_BIND_PORT
kcpBindPort: $DEFAULT_BIND_PORT
quicBindPort: $(($DEFAULT_BIND_PORT + 1))
auth:
  token: $RANDOM_TOKEN
webServer:
  addr: 0.0.0.0
  port: 17500
  user: admin
  password: $RANDOM_WEB_PASSWORD
transport:
  maxPoolCount: 15
allowPorts:
  - start: 11002
    end: 19999
log:
  to: $LOG_DIR
  level: info
  maxDays: 3
EOF

    echo "配置文件创建成功，位于 $CONFIG_FILE"
else
    echo "配置文件已存在，跳过创建步骤。"
fi

# 其他安装和服务启动步骤...

# 定义下载目录
DOWNLOAD_DIR="/tmp/frp_download"

# 创建下载目录
mkdir -p "$DOWNLOAD_DIR"

# 下载最新版本的frps（假设是linux amd64）
FRPS_LATEST_URL=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep "browser_download_url.*frp_.*_linux_amd64.tar.gz" | cut -d '"' -f 4)
wget -O "$DOWNLOAD_DIR/frps_latest.tar.gz" "$FRPS_LATEST_URL"

systemctl stop frps

# 解压并安装
tar zxvf "$DOWNLOAD_DIR/frps_latest.tar.gz" -C "$DOWNLOAD_DIR"
FRPS_DIR=$(tar -tzf "$DOWNLOAD_DIR/frps_latest.tar.gz" | head -1 | cut -f1 -d"/")
cp "$DOWNLOAD_DIR/$FRPS_DIR/frps" /usr/local/bin/

# 清理下载文件
rm -rf "$DOWNLOAD_DIR"

# 创建 Systemd 服务文件
cat <<EOF >/etc/systemd/system/frps.service
[Unit]
Description=frp server service
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frps -c $CONFIG_FILE

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
systemctl daemon-reload
systemctl enable frps
systemctl start frps
systemctl status frps

echo "frps 安装并启动完成！"
