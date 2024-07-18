---
layout: post
title: "Network Configuration Files in Linux"
date:  2022-05-10 10:11:53 +0800
categories: Network
---

[上一篇](https://guo-sj.github.io/network/2022/05/08/switch-and-router.html)文章介绍了我对
路由器和交换机的理解，这一篇我们来讲讲在一个实际的Linux环境（以CentOS为例），网络配置相关
的知识。

在Linux中，一切皆文件。所以我们先来说说网络配置文件。

CentOS的网络配置文件位于`/etc/sysconfig/network-scripts`路径下：
```
$ cd /etc/sysconfig/network-scripts && ls
ifcfg-eth0  ifcfg-eth1 ifdown-eth ifup-eth ...
```
我们可以看到这个目录下大致有两类文件，一类是以`ifcfg-`开头的，是我们机器的NIC（Network Interface Card）
配置文件；另一类是以`ifdown-`或`ifup-`开头的，它们是网络配置脚本文件，具有执行权限。这边我们主要
介绍第一类文件。

我们用`cat`看一个NIC配置文件`ifcfg-eth0`：
```
$ cat ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=UUID=80a6d4b9e864-49548fa5-b6172baab7d1
DEVICE=eth0
ONBOOT=yes
```
可以看到配置的参数有很多，我们从中挑几个重点的解释一下。`BOOTPROTO`这个指定了IP的类型，这里是采取`dhcp`动态向
路由器申请IP，你也可以把它设置为`static`，并指定IP地址，就像这样：
```
... ...
BOOTPROTO=static
IPADDR=192.168.22.56
NETMASK=255.255.255.0
... ...
```

`DEVICE`名指定了NIC的名子，这里是`eth0`。`ONBOOT=yes`表明每次机器启动的时候该NIC会自动启动。`DEFROUTE=yes/IPV6_DEFROUTE=yes`表明
该NIC会被作为IPv4/IPv6的默认路由。

如果你出于某种目的修改了某NIC的配置文件，如`eth0`，那么你需要重启该接口或者整个网络服务来让修改生效：
```
$ ifdown eth0 && ifup eth0
```
或者
```
$ systemctl restart network
```

然后你可以用`ifconfig`命令来查看配置是否生效：
```
$ ifconfig eth0
```

以上。
