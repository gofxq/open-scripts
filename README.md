一键安装frpc服务
```bash
curl -sL https://raw.githubusercontent.com/gofxq/scripts/master/frpc_install.sh  -o /tmp/to_run.sh
sudo bash /tmp/to_run.sh
rm /tmp/to_run.sh
```

一键安装frps服务
```bash
curl -sL https://raw.githubusercontent.com/gofxq/scripts/master/frps_install.sh | \
  sudo bash # 随机token和web秘密
```

or

```bash
curl -sL https://raw.githubusercontent.com/gofxq/scripts/master/frps_install.sh  -o /tmp/to_run.sh
sudo bash /tmp/to_run.sh
rm /tmp/to_run.sh
```