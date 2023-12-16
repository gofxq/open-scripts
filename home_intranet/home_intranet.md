家庭网络拓扑

![home_intranet.png](../src%2Fhome_intranet.png)

# 物理设备
1. AMD 12c24t64g win10ltsc
2. ETH 6c12t64g win10ltsc
3. m1mba 16g MacOS
4. m2mbp 32g MacOS
5. ax3k  路由器
6. cmcc 光猫

## 虚拟机
1. AMD
   1. uamd 12c16g ubuntu
2. ETH
   1. iKuai 1h1g 主路由
   2. OpenWRT 1h1g 透明网关
   3. ueth 6c16g Ubuntu22
   4. win10hv 4h8g win10ltsc
   
# 网络连接
ETH设备配备了两个网络接口：LAN 和 WAN_USB。

其中，WAN_USB 接口专门配置给 iKuai 以便连接到光猫。

而 LAN 接口则分配给 OpenWRT，负责管理下游设备的网络访问。

光猫 cmcc 直接连接到 iKuai，后者充当主路由器角色，处理包括 DNS 在内的核心网络功能。

OpenWRT 作为透明网关，所有下游设备均通过它访问网络。

此外，ax3k 路由器承担无线网络连接的职责，为包括 m1mba 和 m2mbp 在内的所有无线设备提供网络服务。

# 备注
plantuml图使用package表示物理设备