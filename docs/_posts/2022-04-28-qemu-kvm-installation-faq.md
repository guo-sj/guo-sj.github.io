---
layout: post
title: "Qemu KVM Installation FAQ"
date:  2022-04-28 10:30:53 +0800
categories: KVM
---

这篇文章列出了Qemu utility 安装VM过程中我遇到的几个问题，并给
出了相应的解决办法。

**1.** 安装VM的时候需要图形界面，运行命令
```
$ qemu-kvm -name vm1 \
-smp cpus=1 \
-m 1024 \
-cdrom /home/vms/iso/CentOS-7.0-1406-x86_64-DVD.iso \
-drive file=/opt/kvm/vm1.qcow2 \
-netdev bridge,id=tap0,br=br0,helper=/usr/libexec/qemu-bridge-helper
```
时报错：
```
Unable to init server: Could not connect: Connection refused
... ...
gtk initialization failed
```

答：
我用MobaXterm为客户安装的时候出现过这个问题，解决方法详见[这篇文章](https://guo-sj.github.io/kvm/2022/04/28/mobaxterm-linux-gui.html)

**2.** VM可以拷贝的，但是有时在不同场景下，容量需要进行调整，这该怎么做呢？

答：
我在网络上搜索到这样一篇文章，可以解决这个问题，详见[KVM 虚拟机磁盘扩容](https://typesafe.cn/posts/kvm-disk-resize/)。

以上。
