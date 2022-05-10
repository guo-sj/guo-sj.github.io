---
layout: post
title: "Route Tables in Linux"
date:  2022-05-10 11:11:53 +0800
categories: Network
---

[上一篇](https://guo-sj.github.io/network/2022/05/10/network-configure-files-in-linux.html)文章我们介绍了Linux的网络配置文件，
这一篇我们来介绍Linux的路由表（Route Tables）。

用`route -n`来查看当前机器的路由表配置：
```
$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.25.208.1    0.0.0.0         UG    0      0        0 eth0
172.25.208.0    0.0.0.0         255.255.240.0   U     0      0        0 eth0
```

用`route add`命令来增加一条路由规则，如：
```
$ route add -net 192.168.44.0 netmask 255.255.255.0 metric 0 dev eth1
```

用`route del`命令来删除一条路由规则，如：
```
$ route del -net 192.168.44.0 netmask 255.255.255.0 metric 0 eth1
```

在知道这些路由表的基本操作之后，我们来举个例子讲讲路由表的原理。
当收到一个IP Packet，机器首先会和自己的所有的网络接口的IP地址相比对，如果没有匹配，那么
它就认定这个Packet不是给自己的，因此就去查路由表，准备转发。就拿上述的路由表为例，假如
这时机器机器的IP地址为172.25.209.23，但是它收到了一个目的地址为172.25.208.34的IP Packet，
它首先对比目的地址与自己的IP地址，发现不匹配，于是它就去查路由表，查的方法如下：
```
  -->对于一条路由规则
 |         |
 |         V
 |   把需要转发的IP Packet的目的地址与路由规则的Genmask相与，
 |   得到子网号
 |         |
 |         V
 |   把子网号与路由规则的Destination相比较，如果一致就通过
 |   该路由规则的Iface转发出去
 |         |
 ----------
```

用上述方法，显然这个目的地址为172.25.208.34的IP Packet匹配了这台机器路由表的第二条规则，
将会从机器的eth0接口转发出去。接口传到Data Link层，会去查ARP（Address Resolution Protocol）表以
找到目的IP地址的MAC地址，组成Ethernet Frame发出去。ARP 表是一张IP地址 -- MAC地址的哈希表，用来
进行两者之间的映射。

下面我们来讨论两种特殊情况。我们已经知道了路由规则的匹配方法，那么如果一个IP地址匹配了多条
路由规则，这应该如何处理？这个问题我们要分为两种情况进行讨论。

1. 当匹配的多条路由规则的Destination不一样时，比如说机器的路由表变成了这个样子：
```
$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.25.208.1    0.0.0.0         UG    0      0        0 eth0
172.25.208.0    0.0.0.0         255.255.240.0   U     0      0        0 eth0
172.25.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth3
```
根据上述的匹配规则，我们发现172.25.208.34同时匹配了第二条和第三条的路由规则，而且这两条
规则的Destination不同。这时我们根据“Longest Prefix Match”选择第二条规则。

“Longest Prefix Match”意思是当有多条路由规则匹配的时候，我们选取子网掩码最长的那条规则。
这里的“最长”指的是将子网掩码用二进制表示，数字中含有的“1”的部分被称为前缀（Prefix），“1”的位数最多
的就是“最长”的。现在我们回到这个例子，第二条规则的子网掩码为255.255.240.0，换成二进制为11111111.11111111.11110000.00000000；
第三条的子网掩码为255.255.0.0，换成二进制为11111111.11111111.00000000.00000000。显然，
第二条的前缀比第三条的长，因此我们pick第二条路由规则。

2. 当匹配的多条路由规则的Destination一样时，比如说机器的路由表变成了这个样子：
```
$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.25.208.1    0.0.0.0         UG    0      0        0 eth0
172.25.208.0    0.0.0.0         255.255.240.0   U     0      0        0 eth0
172.25.208.0    0.0.0.0         255.255.240.0   U     100    0        0 eth3
```
根据上述的匹配规则，我们发现172.25.208.34同时匹配了第二条和第三条的路由规则，而且这两条
规则的Destination相同。这时因为第二条规则的Metric（0）比第三条的Metric（100）小，所以我们
选择第二条规则。Metric表示Iface到达Destination的距离，Metric越小表示距离越近。当这种情况发生时，
我们选择距Destination最近的那个Iface进行转发。

以上。
