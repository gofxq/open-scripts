### ---------- SSH SOCKS5 代理快速开/关 ---------- ###
# 根据实际情况修改下方变量
export SSH_PROXY_PORT=1080                       # 本地 SOCKS 端口
export SSH_REMOTE_HOST="sshproxy"                    # 远程主机/IP
export SSH_PROXY_SOCKET="$HOME/.ssh/ctrl_path/ssh_proxy_socks"   # 控制套接字

# 开启代理：spon
spon() {
  # 如果 master 已存在就直接返回
  if ssh -S "$SSH_PROXY_SOCKET" -O check "$SSH_REMOTE_HOST" 2>/dev/null; then
    echo "✅ 代理已在运行 (127.0.0.1:$SSH_PROXY_PORT)"
    return 0
  fi

  echo "🚀 正在启动 SSH SOCKS5 代理..."
  ssh -fqNM \
      -D 127.0.0.1:"$SSH_PROXY_PORT" \
      -S "$SSH_PROXY_SOCKET" \
      "$SSH_REMOTE_HOST"
  # TLS加密后的数据是经过高强度加密的密文，其数据熵（随机性）已经很高，接近随机数据。gzip等压缩算法的本质是利用数据中的冗余（即数据的重复性）进行压缩。数据熵越高，重复性越低，可压缩性越差。基本无压缩效果，因此不加-C参数。

  # if [[ $? -eq 0 ]]; then
  #   export http_proxy="socks5://127.0.0.1:$SSH_PROXY_PORT"
  #   export https_proxy="$http_proxy"
  #   export all_proxy="$http_proxy"
  #   echo "✅ 代理已开启：127.0.0.1:$SSH_PROXY_PORT"
  # else
  #   echo "❌ 代理启动失败" >&2
  # fi
}

# 关闭代理：spoff
spoff() {
  # 优雅关闭 master 连接（若还存在）
  ssh -S "$SSH_PROXY_SOCKET" -O exit "$SSH_REMOTE_HOST" &>/dev/null

  # 删除控制套接字文件
  rm -f "$SSH_PROXY_SOCKET"

  # 检测端口是否仍监听
  if lsof -nP -iTCP:"$SSH_PROXY_PORT" -sTCP:LISTEN 2>/dev/null; then
    echo "⚠️ 端口 $SSH_PROXY_PORT 仍在监听，执行清理..."
    pkill -f "ssh.*-D 127.0.0.1:$SSH_PROXY_PORT"
  fi

  # 清理环境变量
  # unset http_proxy https_proxy all_proxy

  echo "✅ 代理已关闭，端口 $SSH_PROXY_PORT 不再监听"
}
