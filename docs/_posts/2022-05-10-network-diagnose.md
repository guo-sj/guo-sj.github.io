---
layout: post
title: "Network Diagonose in Linux"
date:  2022-05-10 12:11:53 +0800
categories: Network
---

在Linux网络配置中，时常会有两个机器Ping不通的情况发生。下面记录一下我的一些诊断思路。

1. 路由表。IP层是整个网络技术的核心，而IP层的核心在于路由表。当两个机器Ping不通的时候，
首先应该看路由表的配置是否正确。用`route -n`来查看机器的路由表：
```
$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.25.208.1    0.0.0.0         UG    0      0        0 eth0
172.25.208.0    0.0.0.0         255.255.240.0   U     0      0        0 eth0
```
路由表的规则表明，当前机器可以通过哪个网络接口（Iface）到达目标网络（Destination）。比如，上述
路由表的第二条规则就表明当前机器可以通过eth0接口到达172.25.208.0这个子网。

2. 网络配置文件。Linux的网络接口配置文件都放在一个路径下。在CentOS中，这个路径为
`/etc/sysconfig/network-scripts/`。当Ping不通时，检查一下该路径中的网络接口配置是否正确。

3. iptables。iptables 是Linux Kernel维护的对于IP Packet的过滤（filter）规则。这里面涉及到
这么几个概念：
    - table：就是实际的过滤规则，如filter和nat
    - Chain：一组过滤规则
    - Target：对于规则采取的措施

可以通过下列命令查看filter表的详细内容：
```
$ iptables -t filter --list   # 也可以把filter换成任何想查看的table，如nat
```

可以通过命令修改filter表的规则，比如下列命令将filter表中的Chain FORWARD由DROP改为ACCEPT：
```
$ iptables -t filter -P FORWARD ACCEPT
```
最近我就是因为一台机器的iptables的filter table的FORWARD为DROP，死活不能ping通它的虚拟机
而被困扰了两天，血淋淋的教训啊。。。

最后，讲一个网络抓包工具“tcpdump”。我们可以用命令`tcpdump -i eth0 -vvv icmp`来监视网卡
eth0的icmp IP Packet的内容。

以上。
