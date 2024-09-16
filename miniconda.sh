#!/bin/bash

# 获取操作系统详细信息
OS=$(uname -s)
ARCH=$(uname -m)

# 设置 Miniconda 的安装文件
if [ "$ARCH" = "x86_64" ]; then
    MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
else
    MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86.sh"
fi

# 下载 Miniconda 安装脚本
wget https://repo.anaconda.com/miniconda/$MINICONDA_INSTALLER -O /tmp/miniconda.sh

# 为安装脚本添加执行权限
chmod +x /tmp/miniconda.sh

# 无交互模式安装 Miniconda
/tmp/miniconda.sh -b -p $HOME/miniconda

# 清理安装脚本
rm /tmp/miniconda.sh

# 初始化 Miniconda，确保 Conda 命令可以在任何新的 shell 会话中使用
$HOME/miniconda/bin/conda init

echo "Miniconda 安装完成！"
