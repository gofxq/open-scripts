# [家庭网络拓扑](home_intranet%2Fhome_intranet.md)

# 配置goproxy

```bash
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

# 添加sudo用户
sudo adduser u
sudo usermod -aG sudo u

# 一键安装frpc服务
```bash
curl -sL https://raw.githubusercontent.com/gofxq/scripts/master/frpc_install.sh  -o /tmp/to_run.sh
sudo bash /tmp/to_run.sh
rm /tmp/to_run.sh
```

# 一键安装frps服务

```bash
# 交互式输入
curl -sL https://raw.githubusercontent.com/gofxq/scripts/master/frps_install.sh  -o /tmp/to_run.sh
sudo bash /tmp/to_run.sh
rm /tmp/to_run.sh
```

or

```bash
# 随机服务端token和web密码
curl -sL https://raw.githubusercontent.com/gofxq/scripts/master/frps_install.sh | \
  sudo bash 
```
