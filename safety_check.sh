#!/bin/bash

# 检查 SSH 是否允许密码登录
if grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config; then
    echo "PasswordAuthentication is enabled. Disabling it now."
    
    # 修改为不允许密码登录
    sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    # 重启 SSH 服务
    sudo systemctl restart sshd
    
    echo "PasswordAuthentication has been disabled and SSH service restarted."
else
    echo "PasswordAuthentication is already disabled."
fi
