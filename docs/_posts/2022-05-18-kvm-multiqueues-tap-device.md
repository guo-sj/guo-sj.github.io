---
layout: post
title: "Enable Multiqueues Tap Device with qemu-kvm"
date:  2022-05-18 10:11:53 +0800
categories: KVM
---

最近收到使能虚拟网卡多对列（Multiqueues Tap）的需求，坑哧坑哧地搞了两天，
总算是实现了。故在此记录一下。

我理解的网卡多对列是针对VM而言的，它可以使用VM的可用的多个vcpu增加网卡的接收效率，突破
VM的网络性能瓶颈。这边有一篇redhat的文档详细介绍了[Multiqueue](https://www.linux-kvm.org/page/Multiqueue#:~:text=macvtap%2Ftap%3A%20For%20single%20queue%20virtio-net%2C%20one%20socket%20of,is%20fact%20a%20multi-queue%20device%20in%20the%20host.)，感兴趣的小伙伴可以阅读一下。

到我这边，我要做的就是要为VM使用两块虚拟网卡tap0，tap3开启多对列，要求是8个对列。
首先，我启动VM的命令如下：
```
$ qemu-kvm -name vm1 -smp cpus=8 -m 8192 -drive file=/opt/kvm/vm1.qcow2 \
    -nic,ifname=tap0,script=no,downscript=no,mac=52:54:00:12:34:00 \
    -daemonize
```

其中，创建`tap0`使用的是以下命令：
```
$ tunctl -t tap0 -u root               # 创建虚拟网卡tap0
$ brctl addif br0 tap0                 # 将创建的br0和tap0连通
$ ifconfig tap0 up                     # 让虚拟网卡tap0启动
```

但是当我用命令`ethtool -l eth0`去看它可用的对列信息的时候，却发现输出这样的错误信息：
```
$ ethtool -l eth0
Channel parameters for eth0
Cannot get device channel parameters
: Operation not supported
```

然后，我根据[Multiqueue](https://www.linux-kvm.org/page/Multiqueue#:~:text=macvtap%2Ftap%3A%20For%20single%20queue%20virtio-net%2C%20one%20socket%20of,is%20fact%20a%20multi-queue%20device%20in%20the%20host.)手册，修改了VM的启动命令：
```
$ qemu-kvm -name vm1 -smp cpus=8 -m 8192 -drive file=/opt/kvm/vm1.qcow2,if=virtio \
    -nic,ifname=tap0,script=no,downscript=no,mac=52:54:00:12:34:00,vhost=on,model=virtio-net-pci,queues=8 \
    -daemonize
```
结果VM直接起不来啦。我寻思着是不是`queues=8`太大了，如果我的tap0不支持多对列的话，应该把
把对列长度改为1，VM就可以起来了。果真如此：
```
$ qemu-kvm -name vm1 -smp cpus=8 -m 8192 -drive file=/opt/kvm/vm1.qcow2,if=virtio \
    -nic,ifname=tap0,script=no,downscript=no,mac=52:54:00:12:34:00,vhost=on,model=virtio-net-pci,queues=1 \
    -daemonize
```

进入虚拟机之后，运行：
```
$ ethtool -l eth0
Pre-set maximums:
RX:             0
TX:             0
Other:          0
Combined:       1
Current hardware settings:
RX:             0
TX:             0
Other:          0
Combined:       1         # current has 1 queues enabled
```
发现可以了，但是只有一个对列，还是相当于没有开启多对列的功能。于是我想着是不是用`tunctl`创建的tap设备不
支持多对列，于是我开始调查如何在Host机器上创建支持多对列的tap设备。

我先是调查了`tunctl`的man page，发现没有关于使能多对列的参数。又看了kernel文档[Universal TUN/TAP device driver](https://www.kernel.org/doc/html/latest/networking/tuntap.html)
并写了程序调用文中给出的`tun_alloc_mq`函数，但是也没有用。

Google的搜索结果显示，大多数人使能多对列都是通过修改VM的xml配置文件完成的，这个xml
文件又是从virt-manager或virt-install命令创建VM的时候生成的。无奈virt-manager和virt-install在我这边的环境（Kylin V10 OS）总是报错，联系客服也没有结果，问题陷入僵局。

到了第二天，我从virt-manager的创建虚拟设备原理入手开始调查。我发现virt-manager是通过
一种叫做`macvtap`的东西，根据[MacVTap - Linux Virtualization Wiki](https://virt.kernelnewbies.org/MacVTap)，
`macvtap`是一种传统的tap设备+网桥的等价物，它可以依附于一个实体
网卡，如eth0，并且在创建的时候会自动创建一个tap设备`/dev/tapX`，然后你用qemu-kvm
起VM的时候可以用`-net,tap,fd=3 3<>/dev/tapX`来指定tap设备。我尝试的`macvtap`命令如下：
```
$ ip link add link eth1 name macvtap0 type macvtap mode bridge # 创建一个bridge模式的macvtap0

$ ip link set set macvtap0 up
```
VM启动命令为：
```
$ qemu-kvm -name vm1 -smp cpus=8 -m 8192 -drive file=/opt/kvm/vm1.qcow2,if=virtio \
    -nic,tap,fd=3 3<>/dev/tap405415 \
    -daemonize
```
`tap405415`是我这边创建`macvtap`设备的时候自动生成的tap设备。
结果起来之后，别说开启网卡多对列了，连Host主机也Ping不通了。。。情况再度陷入僵局。

后来我无意中发现，当起VM的时候，如果不传一个已经创建好的tap设备进去，qemu-kvm会
自动创建一个符合条件的tap设备给VM使用。于是我突发奇想，那么我是否可以将对列的
参数都配好，然后让qemu-kvm给我创建一个符合条件的tap设备呢？

于是我的VM启动命令变成了这样：
```
qemu-kvm -name vm1 -smp cpus=8 -m 8192 \
    -drive file=/opt/kvm/vm1.qcow2,if=virtio \
    -netdev tap,id=dev0,script=no,downscript=no,ifname=tap0,vhost=on,queues=8 \
    -device virtio-net-pci,netdev=dev0,mac=52:54:00:56:78:90,mq=on,vectors=18 \
    -daemonize
```
创建成功！

我进入VM敲下：
```
$ ethtool -l eth0
Pre-set maximums:
RX:             0
TX:             0
Other:          0
Combined:       8
Current hardware settings:
RX:             0
TX:             0
Other:          0
Combined:       8         # current has 8 queues enabled
```

Nice!

不过我发现这样的tap设备虽然可以满足要求，但是它本身并不能连接到我们在
Host机器创建的网桥上，而且用`ifconfig tap0`发现它也没有UP。

小问题，可以用一个脚本来在VM成功启动之后手动添加，就像这样：
```
#!/bin/bash

qemu-kvm -name vm1 -smp cpus=8 -m 8192 \
        -drive file=/opt/kvm/vm1.qcow2,if=virtio \
        -netdev tap,id=dev0,script=no,downscript=no,ifname=tap0,vhost=on,queues=8 \
        -device virtio-net-pci,netdev=dev0,mac=52:54:00:56:78:90,mq=on,vectors=18 \
        -daemonize

if [ $? -eq 0 ];then
        sleep 5
        brctl addif br1 tap0
        ifconfig tap0 up
fi
```

Bingo！大功告成。

以上。
