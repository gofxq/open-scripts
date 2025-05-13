# ------------------------------------------------------------
# 🛰️  SSH SOCKS5 代理快速开/关（Fish Shell）
# ------------------------------------------------------------
# 变量：如需自定义可在外部预先 export；否则用默认值
set -gx SSH_PROXY_PORT    (set -q SSH_PROXY_PORT  ; and echo $SSH_PROXY_PORT  ; or echo 1080)
set -gx SSH_REMOTE_HOST   (set -q SSH_REMOTE_HOST ; and echo $SSH_REMOTE_HOST ; or echo "sshproxy")
set -gx SSH_PROXY_SOCKET  (set -q SSH_PROXY_SOCKET; and echo $SSH_PROXY_SOCKET; or echo "$HOME/.ssh/ctrl_path/ssh_proxy_socks")

# ==== 目录安全 ====
set _sock_dir (dirname $SSH_PROXY_SOCKET)
if not test -d $_sock_dir
  mkdir -p $_sock_dir
  chmod 700  $_sock_dir
end

# ==== 私有工具 ====
function _ctrl_socket_exists
  # test -S => 文件存在且是套接字
  test -S "$SSH_PROXY_SOCKET"
end

function _master_alive
  if _ctrl_socket_exists
    ssh -S "$SSH_PROXY_SOCKET" -O check "$SSH_REMOTE_HOST" ^ /dev/null
  else
    return 1
  end
end

function _set_proxy_env -a _state
  switch $_state
    case on
      set -gx http_proxy  "socks5://127.0.0.1:$SSH_PROXY_PORT"
      set -gx https_proxy $http_proxy
      set -gx all_proxy   $http_proxy
    case off
      set -e http_proxy https_proxy all_proxy
  end
end

# ==== 开启 ====
function spon --description 'Start SSH SOCKS5 proxy'
  if _master_alive
    echo "✅ 代理已在运行 (127.0.0.1:$SSH_PROXY_PORT)"
    return 0
  end

  ssh -fqNM \
    -D 127.0.0.1:$SSH_PROXY_PORT \
    -S "$SSH_PROXY_SOCKET" \
    "$SSH_REMOTE_HOST" ; or begin
      echo "❌ 连接失败，无法启动代理"; return 1
    end

  # 如需全局代理，把下一行解除注释
  # _set_proxy_env on

  echo "🚀 代理已启动 (127.0.0.1:$SSH_PROXY_PORT)"
end

# ==== 关闭 ====
function spoff --description 'Stop SSH SOCKS5 proxy'
  if _ctrl_socket_exists
    ssh -q -S "$SSH_PROXY_SOCKET" -O exit "$SSH_REMOTE_HOST" ^ /dev/null
    rm -f "$SSH_PROXY_SOCKET"
  end

  # 若端口仍监听，仅杀真正占用该端口且为 ssh 的进程
  # 获取占用端口且为 ssh 的进程 PID（安静地）
  set pid (lsof -t -a -c ssh -iTCP:$SSH_PROXY_PORT -sTCP:LISTEN 2>/dev/null)

  if test -n "$pid"
    echo "⚠️ 端口 $SSH_PROXY_PORT 仍在监听，正在清理 ($pid)…"
    command kill $pid
  end



  # 如曾启用全局代理，恢复环境变量
  # _set_proxy_env off

  echo "✅ 代理已关闭，端口 $SSH_PROXY_PORT 不再监听"
end
