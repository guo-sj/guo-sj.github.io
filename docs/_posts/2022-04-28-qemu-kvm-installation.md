---
layout: post
title: "Qemu KVM Installation on Kylin V10 OS "
date:  2022-04-28 10:11:53 +0800
categories: KVM
---

这篇文章记录一下如何在Kylin V10系统中用Qemu KVM安装一个CentOS系统。

Kylin 系统有点像是一个对CentOS进行国产化改造的Linux系统，加强了信息安全方面
的控制。在CentOS或是Ubuntu系统中，如果要装VM(Virtual Machine)的话，可以用软件
`qemu-system-x86_64`，但是在Kylin系统上的仓库中是找不到这个软件的，只能用
`qemu-kvm`。而网上关于`qemu-kvm`的信息很少，质量也不高，导致装的时候非常痛苦，
经过自己不断尝试，终于安装成功，下面讲一下安装的过程。

首先更新缓存：
```
$ yum update && yum clean all && yum makecache
```

然后安装虚拟机所需软件：
```
$ yum install libvirt* qemu* virt-manager -y
```

除此之外，还有一个软件tunctl需要安装，我们先创建
软件所在仓库的配置文件，这一步需要root权限：
```
# vim /etc/yum.repos.d/nux-misc.repo

[nux-misc]
name=Nux Misc
baseurl=http://li.nux.ro/download/nux/misc/el7/x86_64/
enabled=0
gpgcheck=1
gpgkey=http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
```
然后输入以下命令安装tunctl：
```
$ yum --enablerepo=nux-misc install tunctl
```

启动libvirtd服务
```
$ systemctl start libvirtd
```

查看libvirtd的状态：
```
$ systemctl status libvirtd
```

接下来开始配置网络，我们的计划是，先创建一个网桥br0，然后把它和
Host机器的eth3网卡连通，再为VM创建一个虚拟网卡tap0，把tap0和br0
连通，这样的话就可以让VM和Host以桥接的方式连接起来。具体操作如下：
```
$ virsh iface-bridge eth1 br1          # 将物理网卡eth1与br1连通，创建网桥配置文件ifcfg-br1，并启动网桥br1
$ ifconfig br1                         # 此时显示br1的IP地址 
$ ifdown eth1 && ifup eth1 && ifconfig eth1 #重启eth1网卡并查看eth1的信息，因为eth1已经与br1连通，br1已经有IP地址了，所以此时应该不显示IP地址
$ tunctl -t tap0 -u root               # 创建虚拟网卡tap0
$ brctl addif br0 tap0                 # 将创建的br0和tap0连通
$ ifconfig tap0 up                     # 让虚拟网卡tap0启动
```

如果要创建多台VM，那么网桥就不用创建了，只要为新的VM创建虚拟网卡，然后再将
虚拟网卡和网桥相连即可。比如我们还需要创建一台VM，那么对它的网络配置如下：
```
$ tunctl -t tap1 -u root
$ brctl addif br0 tap1
$ ifconfig tap1 up
```

如果网桥或网卡不需要了，可以通过下列命令删除：
```
$ ip link set dev br0 down             # 让网桥br0停止运行
$ brctl delbr br0                      # 删除网桥br0
$ brctl delif br0 tap0                 # 把tap0从网桥br0中删除
$ tunctl -d tap0                       # 删除tap0
```

网络配置好了之后，接下来我们来安装VM。
首先我们创建类型为qcow2的磁盘
```
$ mkdir /opt/kvm
$ qemu-img create -f qcow2 /opt/kvm/vm1.qcow2 5G  # 大小可以自己设置
```

然后我们检查磁盘是否创建成功  
```
$ qemu-img info /opt/kvm/vm1.qcow2
```

接着我们用qemu-kvm 启动虚拟机并安装系统：
```
$ qemu-kvm -name vm1 \
-smp cpus=1 \
-m 1024 \
-cdrom /home/vms/iso/CentOS-7.0-1406-x86_64-DVD.iso \
-drive file=/opt/kvm/vm1.qcow2 \
-netdev bridge,id=tap0,br=br0,helper=/usr/libexec/qemu-bridge-helper
```

如果运行上述命令报错：
```
...
access denied by acl file
qemu-kvm: bridge helper failed
...
```

可以输入以下命令解决：
```
# 为当前用户创建新的qemu配置文件
$ echo "allow all" | sudo tee /etc/qemu/${USER}.conf
$ echo "include /etc/qemu/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
$ sudo chown root:${USER} /etc/qemu/${USER}.conf
$ sudo chmod 640 /etc/qemu/${USER}.conf
```

然后，等待虚拟机安装完成。

虚拟机安装完成之后，把窗口关掉，为虚拟机设定mac地址：
```
$ qemu-kvm -name vm1 -smp cpus=8 -m 8192 -drive file=/opt/kvm/vm1.qcow2 -nic,ifname=tap0,script=no,downscript=no,mac=52:54:00:12:34:00 -daemonize
```

如果需要给虚拟机配置两个网卡tap0和tap1，那么在上述启动命令中再加一个`-nic`的参数即可，如：
```
$ qemu-kvm -name vm1 -smp cpus=8 -m 8192 -drive file=/opt/kvm/vm1.qcow2 -nic,ifname=tap0,script=no,downscript=no,mac=52:54:00:12:34:00 -nic,ifname=tap1,script=no,downscript=no,mac=52:54:00:12:34:01 -daemonize
```

启动之后，用root用户登录，编辑/etc/sysconfig/network-scripts/ifcfg-ens3：
```
# vi /etc/sysconfig/network-scripts/ifcfg-ens3

BOOTPROTO=static
ONBOOT=yes
IPADDR=30.30.30.202      # 设置虚拟机的IP地址，这里eth3的ip地址为30.30.30.201，所以我把虚拟机的IP地址设为30.30.30.202
DEFROUTE=yes
NETMASK=255.255.255.0
GATEWAY=0.0.0.0
TYPE=Ethernet
DEVICE=ens3
NAME=ens3
ZONE=public
```

上面的NETMASK 和GATEWAY与route table中br0保持一致。我们可以这样来查看Host机器的route table 中br0的设置：
```
$ route   # 打印route table
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         gateway         0.0.0.0         UG    100    0        0 eth0
193.160.63.0    0.0.0.0         255.255.255.0   U     100    0        0 eth0
30.30.30.0      0.0.0.0         255.255.255.0   U     0      0        0 br0
```
上述最后一行就是br0的配置，所以我们就把ens3的NETMASK配置为255.255.255.0，GATEWAY
配置为0.0.0.0。

重启网络服务：
```
$ systemctl restart network
```

此时虚拟机就配置好网络了，然后我们可以ping eth3测试一下子：
```
$ ping 30.30.30.201
```

如果对上述安装过程有什么问题，可以参见[KVM FAQ](https://guo-sj.github.io/kvm/2022/04/28/qemu-kvm-installation-faq.html)。

以上。
